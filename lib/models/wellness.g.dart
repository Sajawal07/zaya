// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellness.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWellnessLogCollection on Isar {
  IsarCollection<WellnessLog> get wellnessLogs => this.collection();
}

const WellnessLogSchema = CollectionSchema(
  name: r'WellnessLog',
  id: -1589660912994357124,
  properties: {
    r'acne': PropertySchema(
      id: 0,
      name: r'acne',
      type: IsarType.bool,
    ),
    r'bloating': PropertySchema(
      id: 1,
      name: r'bloating',
      type: IsarType.bool,
    ),
    r'crampsLevel': PropertySchema(
      id: 2,
      name: r'crampsLevel',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 4,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'dietScore': PropertySchema(
      id: 5,
      name: r'dietScore',
      type: IsarType.long,
    ),
    r'facialHair': PropertySchema(
      id: 6,
      name: r'facialHair',
      type: IsarType.bool,
    ),
    r'flowIntensity': PropertySchema(
      id: 7,
      name: r'flowIntensity',
      type: IsarType.string,
    ),
    r'hairThinning': PropertySchema(
      id: 8,
      name: r'hairThinning',
      type: IsarType.bool,
    ),
    r'moodSwingLevel': PropertySchema(
      id: 9,
      name: r'moodSwingLevel',
      type: IsarType.long,
    ),
    r'sleepHours': PropertySchema(
      id: 10,
      name: r'sleepHours',
      type: IsarType.double,
    ),
    r'sleepQuality': PropertySchema(
      id: 11,
      name: r'sleepQuality',
      type: IsarType.long,
    ),
    r'steps': PropertySchema(
      id: 12,
      name: r'steps',
      type: IsarType.long,
    ),
    r'stressLevel': PropertySchema(
      id: 13,
      name: r'stressLevel',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 14,
      name: r'userId',
      type: IsarType.string,
    ),
    r'waterIntake': PropertySchema(
      id: 15,
      name: r'waterIntake',
      type: IsarType.long,
    ),
    r'weight': PropertySchema(
      id: 16,
      name: r'weight',
      type: IsarType.double,
    ),
    r'workoutMinutes': PropertySchema(
      id: 17,
      name: r'workoutMinutes',
      type: IsarType.long,
    )
  },
  estimateSize: _wellnessLogEstimateSize,
  serialize: _wellnessLogSerialize,
  deserialize: _wellnessLogDeserialize,
  deserializeProp: _wellnessLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _wellnessLogGetId,
  getLinks: _wellnessLogGetLinks,
  attach: _wellnessLogAttach,
  version: '3.1.0+1',
);

int _wellnessLogEstimateSize(
  WellnessLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.flowIntensity.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _wellnessLogSerialize(
  WellnessLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.acne);
  writer.writeBool(offsets[1], object.bloating);
  writer.writeLong(offsets[2], object.crampsLevel);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDateTime(offsets[4], object.date);
  writer.writeLong(offsets[5], object.dietScore);
  writer.writeBool(offsets[6], object.facialHair);
  writer.writeString(offsets[7], object.flowIntensity);
  writer.writeBool(offsets[8], object.hairThinning);
  writer.writeLong(offsets[9], object.moodSwingLevel);
  writer.writeDouble(offsets[10], object.sleepHours);
  writer.writeLong(offsets[11], object.sleepQuality);
  writer.writeLong(offsets[12], object.steps);
  writer.writeLong(offsets[13], object.stressLevel);
  writer.writeString(offsets[14], object.userId);
  writer.writeLong(offsets[15], object.waterIntake);
  writer.writeDouble(offsets[16], object.weight);
  writer.writeLong(offsets[17], object.workoutMinutes);
}

WellnessLog _wellnessLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WellnessLog();
  object.acne = reader.readBool(offsets[0]);
  object.bloating = reader.readBool(offsets[1]);
  object.crampsLevel = reader.readLong(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.date = reader.readDateTime(offsets[4]);
  object.dietScore = reader.readLong(offsets[5]);
  object.facialHair = reader.readBool(offsets[6]);
  object.flowIntensity = reader.readString(offsets[7]);
  object.hairThinning = reader.readBool(offsets[8]);
  object.id = id;
  object.moodSwingLevel = reader.readLong(offsets[9]);
  object.sleepHours = reader.readDouble(offsets[10]);
  object.sleepQuality = reader.readLong(offsets[11]);
  object.steps = reader.readLong(offsets[12]);
  object.stressLevel = reader.readLong(offsets[13]);
  object.userId = reader.readString(offsets[14]);
  object.waterIntake = reader.readLong(offsets[15]);
  object.weight = reader.readDoubleOrNull(offsets[16]);
  object.workoutMinutes = reader.readLong(offsets[17]);
  return object;
}

P _wellnessLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _wellnessLogGetId(WellnessLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _wellnessLogGetLinks(WellnessLog object) {
  return [];
}

void _wellnessLogAttach(
    IsarCollection<dynamic> col, Id id, WellnessLog object) {
  object.id = id;
}

extension WellnessLogQueryWhereSort
    on QueryBuilder<WellnessLog, WellnessLog, QWhere> {
  QueryBuilder<WellnessLog, WellnessLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension WellnessLogQueryWhere
    on QueryBuilder<WellnessLog, WellnessLog, QWhereClause> {
  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> userIdNotEqualTo(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> createdAtEqualTo(
      DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> createdAtNotEqualTo(
      DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterWhereClause> createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WellnessLogQueryFilter
    on QueryBuilder<WellnessLog, WellnessLog, QFilterCondition> {
  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> acneEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acne',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> bloatingEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloating',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      crampsLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crampsLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      crampsLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'crampsLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      crampsLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'crampsLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      crampsLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'crampsLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      dietScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietScore',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      dietScoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dietScore',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      dietScoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dietScore',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      dietScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dietScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      facialHairEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'facialHair',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      flowIntensityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'flowIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      flowIntensityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'flowIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      flowIntensityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'flowIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      flowIntensityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'flowIntensity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      flowIntensityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'flowIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      flowIntensityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'flowIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      flowIntensityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'flowIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      flowIntensityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'flowIntensity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      flowIntensityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'flowIntensity',
        value: '',
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      flowIntensityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'flowIntensity',
        value: '',
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      hairThinningEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hairThinning',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      moodSwingLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moodSwingLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      moodSwingLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moodSwingLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      moodSwingLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moodSwingLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      moodSwingLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moodSwingLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      sleepHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      sleepHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      sleepHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      sleepHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      sleepQualityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      sleepQualityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      sleepQualityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      sleepQualityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepQuality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> stepsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'steps',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      stepsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'steps',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> stepsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'steps',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> stepsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'steps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      stressLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stressLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      stressLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stressLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      stressLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stressLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      stressLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stressLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> userIdEqualTo(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> userIdLessThan(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> userIdEndsWith(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> userIdContains(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> userIdMatches(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      waterIntakeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterIntake',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      waterIntakeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waterIntake',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      waterIntakeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waterIntake',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      waterIntakeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waterIntake',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> weightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      weightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> weightEqualTo(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> weightLessThan(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition> weightBetween(
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

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      workoutMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workoutMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      workoutMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workoutMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      workoutMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workoutMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterFilterCondition>
      workoutMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workoutMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WellnessLogQueryObject
    on QueryBuilder<WellnessLog, WellnessLog, QFilterCondition> {}

extension WellnessLogQueryLinks
    on QueryBuilder<WellnessLog, WellnessLog, QFilterCondition> {}

extension WellnessLogQuerySortBy
    on QueryBuilder<WellnessLog, WellnessLog, QSortBy> {
  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByAcne() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acne', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByAcneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acne', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByBloating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloating', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByBloatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloating', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByCrampsLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crampsLevel', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByCrampsLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crampsLevel', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByDietScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietScore', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByDietScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietScore', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByFacialHair() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facialHair', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByFacialHairDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facialHair', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByFlowIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flowIntensity', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy>
      sortByFlowIntensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flowIntensity', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByHairThinning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hairThinning', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy>
      sortByHairThinningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hairThinning', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByMoodSwingLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodSwingLevel', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy>
      sortByMoodSwingLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodSwingLevel', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortBySleepHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHours', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortBySleepHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHours', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortBySleepQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy>
      sortBySleepQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByStepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByStressLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByWaterIntake() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntake', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByWaterIntakeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntake', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> sortByWorkoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutMinutes', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy>
      sortByWorkoutMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutMinutes', Sort.desc);
    });
  }
}

extension WellnessLogQuerySortThenBy
    on QueryBuilder<WellnessLog, WellnessLog, QSortThenBy> {
  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByAcne() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acne', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByAcneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acne', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByBloating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloating', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByBloatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloating', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByCrampsLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crampsLevel', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByCrampsLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crampsLevel', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByDietScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietScore', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByDietScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietScore', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByFacialHair() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facialHair', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByFacialHairDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'facialHair', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByFlowIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flowIntensity', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy>
      thenByFlowIntensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flowIntensity', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByHairThinning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hairThinning', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy>
      thenByHairThinningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hairThinning', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByMoodSwingLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodSwingLevel', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy>
      thenByMoodSwingLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodSwingLevel', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenBySleepHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHours', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenBySleepHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHours', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenBySleepQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy>
      thenBySleepQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByStepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByStressLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByWaterIntake() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntake', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByWaterIntakeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntake', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy> thenByWorkoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutMinutes', Sort.asc);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QAfterSortBy>
      thenByWorkoutMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutMinutes', Sort.desc);
    });
  }
}

extension WellnessLogQueryWhereDistinct
    on QueryBuilder<WellnessLog, WellnessLog, QDistinct> {
  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByAcne() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acne');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByBloating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bloating');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByCrampsLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'crampsLevel');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByDietScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dietScore');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByFacialHair() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'facialHair');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByFlowIntensity(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'flowIntensity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByHairThinning() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hairThinning');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByMoodSwingLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moodSwingLevel');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctBySleepHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepHours');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctBySleepQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepQuality');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'steps');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stressLevel');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByWaterIntake() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waterIntake');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }

  QueryBuilder<WellnessLog, WellnessLog, QDistinct> distinctByWorkoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workoutMinutes');
    });
  }
}

extension WellnessLogQueryProperty
    on QueryBuilder<WellnessLog, WellnessLog, QQueryProperty> {
  QueryBuilder<WellnessLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WellnessLog, bool, QQueryOperations> acneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acne');
    });
  }

  QueryBuilder<WellnessLog, bool, QQueryOperations> bloatingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bloating');
    });
  }

  QueryBuilder<WellnessLog, int, QQueryOperations> crampsLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'crampsLevel');
    });
  }

  QueryBuilder<WellnessLog, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WellnessLog, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<WellnessLog, int, QQueryOperations> dietScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dietScore');
    });
  }

  QueryBuilder<WellnessLog, bool, QQueryOperations> facialHairProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'facialHair');
    });
  }

  QueryBuilder<WellnessLog, String, QQueryOperations> flowIntensityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'flowIntensity');
    });
  }

  QueryBuilder<WellnessLog, bool, QQueryOperations> hairThinningProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hairThinning');
    });
  }

  QueryBuilder<WellnessLog, int, QQueryOperations> moodSwingLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moodSwingLevel');
    });
  }

  QueryBuilder<WellnessLog, double, QQueryOperations> sleepHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepHours');
    });
  }

  QueryBuilder<WellnessLog, int, QQueryOperations> sleepQualityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepQuality');
    });
  }

  QueryBuilder<WellnessLog, int, QQueryOperations> stepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'steps');
    });
  }

  QueryBuilder<WellnessLog, int, QQueryOperations> stressLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stressLevel');
    });
  }

  QueryBuilder<WellnessLog, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<WellnessLog, int, QQueryOperations> waterIntakeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waterIntake');
    });
  }

  QueryBuilder<WellnessLog, double?, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }

  QueryBuilder<WellnessLog, int, QQueryOperations> workoutMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workoutMinutes');
    });
  }
}
