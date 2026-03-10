const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

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
    // We need both the last period date and the FCM token to send a notification
    if (!data.lastPeriodDate || !data.fcmToken) return;

    const lastDate = data.lastPeriodDate.toDate();
    const diffTime = Math.abs(now - lastDate);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    let title = "";
    let body = "";

    // logic for different cycle phases
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
          notification: {
            title: title,
            body: body,
          },
          android: {
            priority: 'high',
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
              },
            },
          },
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
