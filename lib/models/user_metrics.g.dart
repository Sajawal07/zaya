// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_metrics.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserMetricsCollection on Isar {
  IsarCollection<UserMetrics> get userMetrics => this.collection();
}

const UserMetricsSchema = CollectionSchema(
  name: r'UserMetrics',
  id: 3450439425069738250,
  properties: {
    r'acne': PropertySchema(
      id: 0,
      name: r'acne',
      type: IsarType.bool,
    ),
    r'activityLevel': PropertySchema(
      id: 1,
      name: r'activityLevel',
      type: IsarType.string,
    ),
    r'age': PropertySchema(
      id: 2,
      name: r'age',
      type: IsarType.long,
    ),
    r'anxiety': PropertySchema(
      id: 3,
      name: r'anxiety',
      type: IsarType.bool,
    ),
    r'bmi': PropertySchema(
      id: 4,
      name: r'bmi',
      type: IsarType.double,
    ),
    r'bmr': PropertySchema(
      id: 5,
      name: r'bmr',
      type: IsarType.double,
    ),
    r'brainFog': PropertySchema(
      id: 6,
      name: r'brainFog',
      type: IsarType.bool,
    ),
    r'dailyCalorieGoal': PropertySchema(
      id: 7,
      name: r'dailyCalorieGoal',
      type: IsarType.double,
    ),
    r'dueDate': PropertySchema(
      id: 8,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'encryptedSettings': PropertySchema(
      id: 9,
      name: r'encryptedSettings',
      type: IsarType.string,
    ),
    r'facialHair': PropertySchema(
      id: 10,
      name: r'facialHair',
      type: IsarType.bool,
    ),
    r'fatigue': PropertySchema(
      id: 11,
      name: r'fatigue',
      type: IsarType.bool,
    ),
    r'hairFall': PropertySchema(
      id: 12,
      name: r'hairFall',
      type: IsarType.bool,
    ),
    r'hasAmenorrhea': PropertySchema(
      id: 13,
      name: r'hasAmenorrhea',
      type: IsarType.bool,
    ),
    r'hasEndometriosis': PropertySchema(
      id: 14,
      name: r'hasEndometriosis',
      type: IsarType.bool,
    ),
    r'hasFibroids': PropertySchema(
      id: 15,
      name: r'hasFibroids',
      type: IsarType.bool,
    ),
    r'hasPMDD': PropertySchema(
      id: 16,
      name: r'hasPMDD',
      type: IsarType.bool,
    ),
    r'hasThyroid': PropertySchema(
      id: 17,
      name: r'hasThyroid',
      type: IsarType.bool,
    ),
    r'healthCategory': PropertySchema(
      id: 18,
      name: r'healthCategory',
      type: IsarType.string,
    ),
    r'healthMode': PropertySchema(
      id: 19,
      name: r'healthMode',
      type: IsarType.byte,
      enumMap: _UserMetricshealthModeEnumValueMap,
    ),
    r'height': PropertySchema(
      id: 20,
      name: r'height',
      type: IsarType.double,
    ),
    r'irregularPeriods': PropertySchema(
      id: 21,
      name: r'irregularPeriods',
      type: IsarType.bool,
    ),
    r'isMetricsComplete': PropertySchema(
      id: 22,
      name: r'isMetricsComplete',
      type: IsarType.bool,
    ),
    r'isPregnant': PropertySchema(
      id: 23,
      name: r'isPregnant',
      type: IsarType.bool,
    ),
    r'isPremium': PropertySchema(
      id: 24,
      name: r'isPremium',
      type: IsarType.bool,
    ),
    r'lastPeriodDate': PropertySchema(
      id: 25,
      name: r'lastPeriodDate',
      type: IsarType.dateTime,
    ),
    r'lastUpdated': PropertySchema(
      id: 26,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'prePregnancyWeight': PropertySchema(
      id: 27,
      name: r'prePregnancyWeight',
      type: IsarType.double,
    ),
    r'premiumExpiresAt': PropertySchema(
      id: 28,
      name: r'premiumExpiresAt',
      type: IsarType.dateTime,
    ),
    r'recentlyStoppedPill': PropertySchema(
      id: 29,
      name: r'recentlyStoppedPill',
      type: IsarType.bool,
    ),
    r'sleepIssues': PropertySchema(
      id: 30,
      name: r'sleepIssues',
      type: IsarType.bool,
    ),
    r'subscriptionType': PropertySchema(
      id: 31,
      name: r'subscriptionType',
      type: IsarType.string,
    ),
    r'sugarCravings': PropertySchema(
      id: 32,
      name: r'sugarCravings',
      type: IsarType.bool,
    ),
    r'tdee': PropertySchema(
      id: 33,
      name: r'tdee',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 34,
      name: r'userId',
      type: IsarType.string,
    ),
    r'weight': PropertySchema(
      id: 35,
      name: r'weight',
      type: IsarType.double,
    )
  },
  estimateSize: _userMetricsEstimateSize,
  serialize: _userMetricsSerialize,
  deserialize: _userMetricsDeserialize,
  deserializeProp: _userMetricsDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _userMetricsGetId,
  getLinks: _userMetricsGetLinks,
  attach: _userMetricsAttach,
  version: '3.1.0+1',
);

int _userMetricsEstimateSize(
  UserMetrics object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.activityLevel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.encryptedSettings;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.healthCategory.length * 3;
  {
    final value = object.subscriptionType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _userMetricsSerialize(
  UserMetrics object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.acne);
  writer.writeString(offsets[1], object.activityLevel);
  writer.writeLong(offsets[2], object.age);
  writer.writeBool(offsets[3], object.anxiety);
  writer.writeDouble(offsets[4], object.bmi);
  writer.writeDouble(offsets[5], object.bmr);
  writer.writeBool(offsets[6], object.brainFog);
  writer.writeDouble(offsets[7], object.dailyCalorieGoal);
  writer.writeDateTime(offsets[8], object.dueDate);
  writer.writeString(offsets[9], object.encryptedSettings);
  writer.writeBool(offsets[10], object.facialHair);
  writer.writeBool(offsets[11], object.fatigue);
  writer.writeBool(offsets[12], object.hairFall);
  writer.writeBool(offsets[13], object.hasAmenorrhea);
  writer.writeBool(offsets[14], object.hasEndometriosis);
  writer.writeBool(offsets[15], object.hasFibroids);
  writer.writeBool(offsets[16], object.hasPMDD);
  writer.writeBool(offsets[17], object.hasThyroid);
  writer.writeString(offsets[18], object.healthCategory);
  writer.writeByte(offsets[19], object.healthMode.index);
  writer.writeDouble(offsets[20], object.height);
  writer.writeBool(offsets[21], object.irregularPeriods);
  writer.writeBool(offsets[22], object.isMetricsComplete);
  writer.writeBool(offsets[23], object.isPregnant);
  writer.writeBool(offsets[24], object.isPremium);
  writer.writeDateTime(offsets[25], object.lastPeriodDate);
  writer.writeDateTime(offsets[26], object.lastUpdated);
  writer.writeDouble(offsets[27], object.prePregnancyWeight);
  writer.writeDateTime(offsets[28], object.premiumExpiresAt);
  writer.writeBool(offsets[29], object.recentlyStoppedPill);
  writer.writeBool(offsets[30], object.sleepIssues);
  writer.writeString(offsets[31], object.subscriptionType);
  writer.writeBool(offsets[32], object.sugarCravings);
  writer.writeDouble(offsets[33], object.tdee);
  writer.writeString(offsets[34], object.userId);
  writer.writeDouble(offsets[35], object.weight);
}

UserMetrics _userMetricsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserMetrics();
  object.acne = reader.readBool(offsets[0]);
  object.activityLevel = reader.readStringOrNull(offsets[1]);
  object.age = reader.readLongOrNull(offsets[2]);
  object.anxiety = reader.readBool(offsets[3]);
  object.brainFog = reader.readBool(offsets[6]);
  object.dueDate = reader.readDateTimeOrNull(offsets[8]);
  object.encryptedSettings = reader.readStringOrNull(offsets[9]);
  object.facialHair = reader.readBool(offsets[10]);
  object.fatigue = reader.readBool(offsets[11]);
  object.hairFall = reader.readBool(offsets[12]);
  object.hasAmenorrhea = reader.readBool(offsets[13]);
  object.hasEndometriosis = reader.readBool(offsets[14]);
  object.hasFibroids = reader.readBool(offsets[15]);
  object.hasPMDD = reader.readBool(offsets[16]);
  object.hasThyroid = reader.readBool(offsets[17]);
  object.healthMode =
      _UserMetricshealthModeValueEnumMap[reader.readByteOrNull(offsets[19])] ??
          HealthMode.standard;
  object.height = reader.readDoubleOrNull(offsets[20]);
  object.id = id;
  object.irregularPeriods = reader.readBool(offsets[21]);
  object.isPregnant = reader.readBool(offsets[23]);
  object.isPremium = reader.readBool(offsets[24]);
  object.lastPeriodDate = reader.readDateTimeOrNull(offsets[25]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[26]);
  object.prePregnancyWeight = reader.readDoubleOrNull(offsets[27]);
  object.premiumExpiresAt = reader.readDateTimeOrNull(offsets[28]);
  object.recentlyStoppedPill = reader.readBool(offsets[29]);
  object.sleepIssues = reader.readBool(offsets[30]);
  object.subscriptionType = reader.readStringOrNull(offsets[31]);
  object.sugarCravings = reader.readBool(offsets[32]);
  object.userId = reader.readString(offsets[34]);
  object.weight = reader.readDoubleOrNull(offsets[35]);
  return object;
}

P _userMetricsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (_UserMetricshealthModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          HealthMode.standard) as P;
    case 20:
      return (reader.readDoubleOrNull(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (reader.readBool(offset)) as P;
    case 23:
      return (reader.readBool(offset)) as P;
    case 24:
      return (reader.readBool(offset)) as P;
    case 25:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 26:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 27:
      return (reader.readDoubleOrNull(offset)) as P;
    case 28:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 29:
      return (reader.readBool(offset)) as P;
    case 30:
      return (reader.readBool(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readBool(offset)) as P;
    case 33:
      return (reader.readDouble(offset)) as P;
    case 34:
      return (reader.readString(offset)) as P;
    case 35:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _UserMetricshealthModeEnumValueMap = {
  'standard': 0,
  'pcos': 1,
  'pregnancy': 2,
  'ttc': 3,
};
const _UserMetricshealthModeValueEnumMap = {
  0: HealthMode.standard,
  1: HealthMode.pcos,
  2: HealthMode.pregnancy,
  3: HealthMode.ttc,
};

Id _userMetricsGetId(UserMetrics object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userMetricsGetLinks(UserMetrics object) {
  return [];
}

void _userMetricsAttach(
    IsarCollection<dynamic> col, Id id, UserMetrics object) {
  object.id = id;
}

extension UserMetricsByIndex on IsarCollection<UserMetrics> {
  Future<UserMetrics?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  UserMetrics? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<UserMetrics?>> getAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<UserMetrics?> getAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'userId', values);
  }

  Future<int> deleteAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'userId', values);
  }

  int deleteAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'userId', values);
  }

  Future<Id> putByUserId(UserMetrics object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(UserMetrics object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<UserMetrics> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<UserMetrics> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension UserMetricsQueryWhereSort
    on QueryBuilder<UserMetrics, UserMetrics, QWhere> {
  QueryBuilder<UserMetrics, UserMetrics, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserMetricsQueryWhere
    on QueryBuilder<UserMetrics, UserMetrics, QWhereClause> {
  QueryBuilder<UserMetrics, UserMetrics, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterWhereClause> userIdNotEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension UserMetricsQueryFilter
    on QueryBuilder<UserMetrics, UserMetrics, QFilterCondition> {
  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> acneEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acne',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activityLevel',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activityLevel',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      activityLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> ageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'age',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> ageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'age',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> ageEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> ageGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> ageLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> ageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'age',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> anxietyEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'anxiety',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> bmiEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bmi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> bmiGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bmi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> bmiLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bmi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> bmiBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bmi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> bmrEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bmr',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> bmrGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bmr',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> bmrLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bmr',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> bmrBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bmr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> brainFogEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brainFog',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      dailyCalorieGoalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyCalorieGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      dailyCalorieGoalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyCalorieGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      dailyCalorieGoalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyCalorieGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      dailyCalorieGoalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyCalorieGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      dueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      dueDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> dueDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      dueDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> dueDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> dueDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'encryptedSettings',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'encryptedSettings',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedSettings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'encryptedSettings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'encryptedSettings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'encryptedSettings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'encryptedSettings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'encryptedSettings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'encryptedSettings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'encryptedSettings',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedSettings',
        value: '',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      encryptedSettingsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'encryptedSettings',
        value: '',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      facialHairEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'facialHair',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> fatigueEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatigue',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> hairFallEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hairFall',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      hasAmenorrheaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasAmenorrhea',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      hasEndometriosisEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasEndometriosis',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      hasFibroidsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasFibroids',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> hasPMDDEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasPMDD',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      hasThyroidEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasThyroid',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthCategoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthCategoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'healthCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthCategoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'healthCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthCategoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'healthCategory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthCategoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'healthCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthCategoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'healthCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthCategoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'healthCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthCategoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'healthCategory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthCategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthCategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'healthCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthModeEqualTo(HealthMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthModeGreaterThan(
    HealthMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'healthMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthModeLessThan(
    HealthMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'healthMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      healthModeBetween(
    HealthMode lower,
    HealthMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'healthMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> heightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'height',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      heightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'height',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> heightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      heightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> heightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> heightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      irregularPeriodsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'irregularPeriods',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      isMetricsCompleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMetricsComplete',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      isPregnantEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPregnant',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      isPremiumEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPremium',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastPeriodDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPeriodDate',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastPeriodDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPeriodDate',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastPeriodDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPeriodDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastPeriodDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPeriodDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastPeriodDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPeriodDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastPeriodDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPeriodDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      prePregnancyWeightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'prePregnancyWeight',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      prePregnancyWeightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'prePregnancyWeight',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      prePregnancyWeightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prePregnancyWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      prePregnancyWeightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prePregnancyWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      prePregnancyWeightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prePregnancyWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      prePregnancyWeightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prePregnancyWeight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      premiumExpiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'premiumExpiresAt',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      premiumExpiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'premiumExpiresAt',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      premiumExpiresAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'premiumExpiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      premiumExpiresAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'premiumExpiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      premiumExpiresAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'premiumExpiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      premiumExpiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'premiumExpiresAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      recentlyStoppedPillEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recentlyStoppedPill',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      sleepIssuesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepIssues',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subscriptionType',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subscriptionType',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscriptionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subscriptionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subscriptionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subscriptionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subscriptionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subscriptionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subscriptionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subscriptionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscriptionType',
        value: '',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      subscriptionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subscriptionType',
        value: '',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      sugarCravingsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sugarCravings',
        value: value,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> tdeeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tdee',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> tdeeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tdee',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> tdeeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tdee',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> tdeeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tdee',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> userIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> weightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      weightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> weightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition>
      weightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> weightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterFilterCondition> weightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension UserMetricsQueryObject
    on QueryBuilder<UserMetrics, UserMetrics, QFilterCondition> {}

extension UserMetricsQueryLinks
    on QueryBuilder<UserMetrics, UserMetrics, QFilterCondition> {}

extension UserMetricsQuerySortBy
    on QueryBuilder<UserMetrics, UserMetrics, QSortBy> {
  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByAcne() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acne', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByAcneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acne', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByActivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByActivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByAnxiety() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'anxiety', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByAnxietyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'anxiety', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByBmi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmi', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByBmiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmi', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByBmr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmr', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByBmrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmr', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByBrainFog() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brainFog', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByBrainFogDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brainFog', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByDailyCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCalorieGoal', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByDailyCalorieGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCalorieGoal', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByEncryptedSettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedSettings', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByEncryptedSettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedSettings', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByFacialHair() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facialHair', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByFacialHairDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facialHair', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByFatigue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatigue', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByFatigueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatigue', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHairFall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hairFall', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHairFallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hairFall', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHasAmenorrhea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAmenorrhea', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByHasAmenorrheaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAmenorrhea', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByHasEndometriosis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasEndometriosis', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByHasEndometriosisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasEndometriosis', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHasFibroids() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFibroids', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHasFibroidsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFibroids', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHasPMDD() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPMDD', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHasPMDDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPMDD', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHasThyroid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasThyroid', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHasThyroidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasThyroid', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHealthCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthCategory', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByHealthCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthCategory', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHealthMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthMode', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHealthModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthMode', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByIrregularPeriods() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'irregularPeriods', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByIrregularPeriodsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'irregularPeriods', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByIsMetricsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetricsComplete', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByIsMetricsCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetricsComplete', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByIsPregnant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPregnant', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByIsPregnantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPregnant', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByIsPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByIsPremiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByLastPeriodDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPeriodDate', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByLastPeriodDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPeriodDate', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByPrePregnancyWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prePregnancyWeight', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByPrePregnancyWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prePregnancyWeight', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByPremiumExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'premiumExpiresAt', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByPremiumExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'premiumExpiresAt', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByRecentlyStoppedPill() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recentlyStoppedPill', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortByRecentlyStoppedPillDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recentlyStoppedPill', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortBySleepIssues() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepIssues', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortBySleepIssuesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepIssues', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortBySubscriptionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionType', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortBySubscriptionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionType', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortBySugarCravings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarCravings', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      sortBySugarCravingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarCravings', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByTdee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdee', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByTdeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdee', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension UserMetricsQuerySortThenBy
    on QueryBuilder<UserMetrics, UserMetrics, QSortThenBy> {
  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByAcne() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acne', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByAcneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acne', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByActivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByActivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByAnxiety() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'anxiety', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByAnxietyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'anxiety', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByBmi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmi', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByBmiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmi', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByBmr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmr', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByBmrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmr', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByBrainFog() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brainFog', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByBrainFogDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brainFog', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByDailyCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCalorieGoal', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByDailyCalorieGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCalorieGoal', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByEncryptedSettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedSettings', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByEncryptedSettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedSettings', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByFacialHair() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facialHair', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByFacialHairDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facialHair', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByFatigue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatigue', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByFatigueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatigue', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHairFall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hairFall', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHairFallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hairFall', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHasAmenorrhea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAmenorrhea', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByHasAmenorrheaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAmenorrhea', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByHasEndometriosis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasEndometriosis', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByHasEndometriosisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasEndometriosis', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHasFibroids() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFibroids', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHasFibroidsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFibroids', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHasPMDD() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPMDD', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHasPMDDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPMDD', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHasThyroid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasThyroid', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHasThyroidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasThyroid', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHealthCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthCategory', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByHealthCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthCategory', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHealthMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthMode', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHealthModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthMode', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByIrregularPeriods() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'irregularPeriods', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByIrregularPeriodsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'irregularPeriods', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByIsMetricsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetricsComplete', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByIsMetricsCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetricsComplete', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByIsPregnant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPregnant', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByIsPregnantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPregnant', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByIsPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByIsPremiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByLastPeriodDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPeriodDate', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByLastPeriodDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPeriodDate', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByPrePregnancyWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prePregnancyWeight', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByPrePregnancyWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prePregnancyWeight', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByPremiumExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'premiumExpiresAt', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByPremiumExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'premiumExpiresAt', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByRecentlyStoppedPill() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recentlyStoppedPill', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenByRecentlyStoppedPillDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recentlyStoppedPill', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenBySleepIssues() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepIssues', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenBySleepIssuesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepIssues', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenBySubscriptionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionType', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenBySubscriptionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionType', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenBySugarCravings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarCravings', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy>
      thenBySugarCravingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarCravings', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByTdee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdee', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByTdeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdee', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QAfterSortBy> thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension UserMetricsQueryWhereDistinct
    on QueryBuilder<UserMetrics, UserMetrics, QDistinct> {
  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByAcne() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acne');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByActivityLevel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityLevel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'age');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByAnxiety() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'anxiety');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByBmi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bmi');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByBmr() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bmr');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByBrainFog() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brainFog');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct>
      distinctByDailyCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyCalorieGoal');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByEncryptedSettings(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encryptedSettings',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByFacialHair() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'facialHair');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByFatigue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatigue');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByHairFall() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hairFall');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByHasAmenorrhea() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasAmenorrhea');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct>
      distinctByHasEndometriosis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasEndometriosis');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByHasFibroids() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasFibroids');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByHasPMDD() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasPMDD');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByHasThyroid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasThyroid');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByHealthCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'healthCategory',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByHealthMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'healthMode');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct>
      distinctByIrregularPeriods() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'irregularPeriods');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct>
      distinctByIsMetricsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMetricsComplete');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByIsPregnant() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPregnant');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByIsPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPremium');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByLastPeriodDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPeriodDate');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct>
      distinctByPrePregnancyWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prePregnancyWeight');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct>
      distinctByPremiumExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'premiumExpiresAt');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct>
      distinctByRecentlyStoppedPill() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recentlyStoppedPill');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctBySleepIssues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepIssues');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctBySubscriptionType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subscriptionType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctBySugarCravings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sugarCravings');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByTdee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tdee');
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserMetrics, UserMetrics, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension UserMetricsQueryProperty
    on QueryBuilder<UserMetrics, UserMetrics, QQueryProperty> {
  QueryBuilder<UserMetrics, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> acneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acne');
    });
  }

  QueryBuilder<UserMetrics, String?, QQueryOperations> activityLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityLevel');
    });
  }

  QueryBuilder<UserMetrics, int?, QQueryOperations> ageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'age');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> anxietyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'anxiety');
    });
  }

  QueryBuilder<UserMetrics, double, QQueryOperations> bmiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bmi');
    });
  }

  QueryBuilder<UserMetrics, double, QQueryOperations> bmrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bmr');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> brainFogProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brainFog');
    });
  }

  QueryBuilder<UserMetrics, double, QQueryOperations>
      dailyCalorieGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyCalorieGoal');
    });
  }

  QueryBuilder<UserMetrics, DateTime?, QQueryOperations> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<UserMetrics, String?, QQueryOperations>
      encryptedSettingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedSettings');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> facialHairProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'facialHair');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> fatigueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatigue');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> hairFallProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hairFall');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> hasAmenorrheaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasAmenorrhea');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> hasEndometriosisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasEndometriosis');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> hasFibroidsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasFibroids');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> hasPMDDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasPMDD');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> hasThyroidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasThyroid');
    });
  }

  QueryBuilder<UserMetrics, String, QQueryOperations> healthCategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'healthCategory');
    });
  }

  QueryBuilder<UserMetrics, HealthMode, QQueryOperations> healthModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'healthMode');
    });
  }

  QueryBuilder<UserMetrics, double?, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> irregularPeriodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'irregularPeriods');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations>
      isMetricsCompleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMetricsComplete');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> isPregnantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPregnant');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> isPremiumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPremium');
    });
  }

  QueryBuilder<UserMetrics, DateTime?, QQueryOperations>
      lastPeriodDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPeriodDate');
    });
  }

  QueryBuilder<UserMetrics, DateTime?, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<UserMetrics, double?, QQueryOperations>
      prePregnancyWeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prePregnancyWeight');
    });
  }

  QueryBuilder<UserMetrics, DateTime?, QQueryOperations>
      premiumExpiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'premiumExpiresAt');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations>
      recentlyStoppedPillProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recentlyStoppedPill');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> sleepIssuesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepIssues');
    });
  }

  QueryBuilder<UserMetrics, String?, QQueryOperations>
      subscriptionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subscriptionType');
    });
  }

  QueryBuilder<UserMetrics, bool, QQueryOperations> sugarCravingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sugarCravings');
    });
  }

  QueryBuilder<UserMetrics, double, QQueryOperations> tdeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tdee');
    });
  }

  QueryBuilder<UserMetrics, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<UserMetrics, double?, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}
