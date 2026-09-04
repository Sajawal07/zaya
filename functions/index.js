const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { google } = require('googleapis');

admin.initializeApp();

// Server-trusted package configuration (never trust package name sent by client)
const APP_PACKAGE_NAME = 'com.hercycle.bloom';
const ALLOWED_PRODUCT_IDS = ['premium_upgrade'];

/**
 * Server-Side Firebase Cloud Function to verify Google Play In-App Purchases.
 * Uses Android Publisher API v3 (purchases.products.get) to validate tokens against Google Play.
 * Enforces atomic transaction token replay protection and updates Firestore using Admin SDK.
 */
exports.verifyGooglePlayPurchase = functions.https.onCall(async (data, context) => {
  // 1. Enforce Authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'The function must be called while authenticated.'
    );
  }

  const uid = context.auth.uid;
  const { productId, purchaseToken } = data;

  if (!productId || !purchaseToken) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required parameters: productId or purchaseToken.'
    );
  }

  if (!ALLOWED_PRODUCT_IDS.includes(productId)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Invalid product ID requested.'
    );
  }

  const db = admin.firestore();
  const tokenDocRef = db.collection('purchase_tokens').doc(purchaseToken);
  const userDocRef = db.collection('users').doc(uid);

  // 2. Initialize Google Auth Client using Service Account
  const auth = new google.auth.GoogleAuth({
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  });
  const authClient = await auth.getClient();
  const androidPublisher = google.androidpublisher({
    version: 'v3',
    auth: authClient,
  });

  // 3. Verify Purchase with Google Play Developer API (purchases.products.get)
  const response = await androidPublisher.purchases.products.get({
    packageName: APP_PACKAGE_NAME,
    productId: productId,
    token: purchaseToken,
  });

  const purchaseState = response.data.purchaseState; // 0 = Purchased, 1 = Canceled, 2 = Pending

  if (purchaseState !== 0) {
    console.warn(`Non-purchased state (${purchaseState}) received for user ${uid}`);
    throw new functions.https.HttpsError(
      'permission-denied',
      'Google Play returned non-active purchase state.'
    );
  }

  // 4. True Firestore Transaction for Atomic Replay Protection & Entitlement Granting
  await db.runTransaction(async (transaction) => {
    const tokenSnapshot = await transaction.get(tokenDocRef);

    if (tokenSnapshot.exists) {
      const existingUserId = tokenSnapshot.data().userId;
      if (existingUserId !== uid) {
        // Replay attack: Another user account is attempting to claim this purchase token!
        console.warn(`Replay attack prevented for user ${uid}`);
        throw new functions.https.HttpsError(
          'already-exists',
          'This purchase token is already registered to another account.'
        );
      }
    }

    // Record token ownership
    transaction.set(tokenDocRef, {
      userId: uid,
      productId: productId,
      packageName: APP_PACKAGE_NAME,
      purchaseTimeMillis: response.data.purchaseTimeMillis || Date.now(),
      verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Grant entitlement in user document via Admin SDK (bypassing client write rules)
    transaction.set(userDocRef, {
      isPremium: true,
      subscriptionType: productId,
      purchaseToken: purchaseToken,
      verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  });

  console.log(`Successfully verified Google Play purchase for user ${uid}, product: ${productId}`);

  return {
    success: true,
    isPremium: true,
    productId: productId,
  };
});

/**
 * Daily scheduled task to check all users' cycles.
 * Sends notifications for Ovulation (Day 12), Missed Logging (Day 29),
 * and Late Periods (Day 36+).
 */
exports.checkCyclesDaily = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  const now = new Date();
  const usersSnapshot = await admin.firestore().collection('users').get();
  
  const notifications = [];

  usersSnapshot.forEach(doc => {
    const data = doc.data();
    if (!data.lastPeriodDate || !data.fcmToken) return;

    const lastDate = data.lastPeriodDate.toDate();
    const diffTime = Math.abs(now - lastDate);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    let title = "";
    let body = "";

    if (diffDays === 12) {
      title = "Ovulation Day! 🌸";
      body = "Today is your ovulation day. Best time to try to conceive!";
    } else if (diffDays > 35) {
      title = "Period Significantly Late ⚠️";
      body = "Your period is significantly delayed. If not trying to conceive, consult a doctor. If trying to conceive, consider a pregnancy test.";
    } else if (diffDays >= 29) {
      title = "Missed Logging? 🔔";
      body = "It looks like your period may have started. Please log it in the Haya app for accurate tracking.";
    }

    if (title && body) {
      notifications.push(
        admin.messaging().send({
          token: data.fcmToken,
          notification: { title: title, body: body },
          android: { priority: 'high' },
          apns: { payload: { aps: { sound: 'default' } } },
        })
      );
    }
  });

  try {
    const results = await Promise.all(notifications);
    console.log(`Successfully sent ${results.length} notifications.`);
  } catch (error) {
    console.error('Error sending notifications:', error);
  }
  
  return null;
});
