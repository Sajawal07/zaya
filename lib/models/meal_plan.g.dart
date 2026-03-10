// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyMealPlanCollection on Isar {
  IsarCollection<DailyMealPlan> get dailyMealPlans => this.collection();
}

const DailyMealPlanSchema = CollectionSchema(
  name: r'DailyMealPlan',
  id: 9127885714758400261,
  properties: {
    r'breakfastPortion': PropertySchema(
      id: 0,
      name: r'breakfastPortion',
      type: IsarType.double,
    ),
    r'breakfastRecipeId': PropertySchema(
      id: 1,
      name: r'breakfastRecipeId',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'dinnerPortion': PropertySchema(
      id: 3,
      name: r'dinnerPortion',
      type: IsarType.double,
    ),
    r'dinnerRecipeId': PropertySchema(
      id: 4,
      name: r'dinnerRecipeId',
      type: IsarType.string,
    ),
    r'loggedMealTypes': PropertySchema(
      id: 5,
      name: r'loggedMealTypes',
      type: IsarType.stringList,
    ),
    r'lunchPortion': PropertySchema(
      id: 6,
      name: r'lunchPortion',
      type: IsarType.double,
    ),
    r'lunchRecipeId': PropertySchema(
      id: 7,
      name: r'lunchRecipeId',
      type: IsarType.string,
    ),
    r'pcosPattern': PropertySchema(
      id: 8,
      name: r'pcosPattern',
      type: IsarType.string,
    ),
    r'snackRecipeIds': PropertySchema(
      id: 9,
      name: r'snackRecipeIds',
      type: IsarType.stringList,
    ),
    r'userId': PropertySchema(
      id: 10,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _dailyMealPlanEstimateSize,
  serialize: _dailyMealPlanSerialize,
  deserialize: _dailyMealPlanDeserialize,
  deserializeProp: _dailyMealPlanDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyMealPlanGetId,
  getLinks: _dailyMealPlanGetLinks,
  attach: _dailyMealPlanAttach,
  version: '3.1.0+1',
);

int _dailyMealPlanEstimateSize(
  DailyMealPlan object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.breakfastRecipeId.length * 3;
  bytesCount += 3 + object.dinnerRecipeId.length * 3;
  bytesCount += 3 + object.loggedMealTypes.length * 3;
  {
    for (var i = 0; i < object.loggedMealTypes.length; i++) {
      final value = object.loggedMealTypes[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.lunchRecipeId.length * 3;
  bytesCount += 3 + object.pcosPattern.length * 3;
  bytesCount += 3 + object.snackRecipeIds.length * 3;
  {
    for (var i = 0; i < object.snackRecipeIds.length; i++) {
      final value = object.snackRecipeIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _dailyMealPlanSerialize(
  DailyMealPlan object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.breakfastPortion);
  writer.writeString(offsets[1], object.breakfastRecipeId);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeDouble(offsets[3], object.dinnerPortion);
  writer.writeString(offsets[4], object.dinnerRecipeId);
  writer.writeStringList(offsets[5], object.loggedMealTypes);
  writer.writeDouble(offsets[6], object.lunchPortion);
  writer.writeString(offsets[7], object.lunchRecipeId);
  writer.writeString(offsets[8], object.pcosPattern);
  writer.writeStringList(offsets[9], object.snackRecipeIds);
  writer.writeString(offsets[10], object.userId);
}

DailyMealPlan _dailyMealPlanDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyMealPlan();
  object.breakfastPortion = reader.readDouble(offsets[0]);
  object.breakfastRecipeId = reader.readString(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.dinnerPortion = reader.readDouble(offsets[3]);
  object.dinnerRecipeId = reader.readString(offsets[4]);
  object.id = id;
  object.loggedMealTypes = reader.readStringList(offsets[5]) ?? [];
  object.lunchPortion = reader.readDouble(offsets[6]);
  object.lunchRecipeId = reader.readString(offsets[7]);
  object.pcosPattern = reader.readString(offsets[8]);
  object.snackRecipeIds = reader.readStringList(offsets[9]) ?? [];
  object.userId = reader.readString(offsets[10]);
  return object;
}

P _dailyMealPlanDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyMealPlanGetId(DailyMealPlan object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyMealPlanGetLinks(DailyMealPlan object) {
  return [];
}

void _dailyMealPlanAttach(
    IsarCollection<dynamic> col, Id id, DailyMealPlan object) {
  object.id = id;
}

extension DailyMealPlanQueryWhereSort
    on QueryBuilder<DailyMealPlan, DailyMealPlan, QWhere> {
  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension DailyMealPlanQueryWhere
    on QueryBuilder<DailyMealPlan, DailyMealPlan, QWhereClause> {
  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> idBetween(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> dateNotEqualTo(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> dateGreaterThan(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> dateLessThan(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterWhereClause> dateBetween(
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
}

extension DailyMealPlanQueryFilter
    on QueryBuilder<DailyMealPlan, DailyMealPlan, QFilterCondition> {
  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastPortionEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breakfastPortion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastPortionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'breakfastPortion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastPortionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'breakfastPortion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastPortionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'breakfastPortion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastRecipeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breakfastRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastRecipeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'breakfastRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastRecipeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'breakfastRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastRecipeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'breakfastRecipeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastRecipeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'breakfastRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastRecipeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'breakfastRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastRecipeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'breakfastRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastRecipeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'breakfastRecipeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastRecipeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breakfastRecipeId',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      breakfastRecipeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'breakfastRecipeId',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dateGreaterThan(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dateLessThan(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition> dateBetween(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerPortionEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dinnerPortion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerPortionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dinnerPortion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerPortionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dinnerPortion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerPortionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dinnerPortion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerRecipeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dinnerRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerRecipeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dinnerRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerRecipeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dinnerRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerRecipeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dinnerRecipeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerRecipeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dinnerRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerRecipeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dinnerRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerRecipeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dinnerRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerRecipeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dinnerRecipeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerRecipeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dinnerRecipeId',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      dinnerRecipeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dinnerRecipeId',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loggedMealTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loggedMealTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loggedMealTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loggedMealTypes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'loggedMealTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'loggedMealTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loggedMealTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loggedMealTypes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loggedMealTypes',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loggedMealTypes',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loggedMealTypes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loggedMealTypes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loggedMealTypes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loggedMealTypes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loggedMealTypes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      loggedMealTypesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loggedMealTypes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchPortionEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lunchPortion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchPortionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lunchPortion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchPortionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lunchPortion',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchPortionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lunchPortion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchRecipeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lunchRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchRecipeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lunchRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchRecipeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lunchRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchRecipeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lunchRecipeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchRecipeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lunchRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchRecipeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lunchRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchRecipeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lunchRecipeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchRecipeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lunchRecipeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchRecipeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lunchRecipeId',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      lunchRecipeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lunchRecipeId',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      pcosPatternEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pcosPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      pcosPatternGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pcosPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      pcosPatternLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pcosPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      pcosPatternBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pcosPattern',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      pcosPatternStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pcosPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      pcosPatternEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pcosPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      pcosPatternContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pcosPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      pcosPatternMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pcosPattern',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      pcosPatternIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pcosPattern',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      pcosPatternIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pcosPattern',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snackRecipeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'snackRecipeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'snackRecipeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'snackRecipeIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'snackRecipeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'snackRecipeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'snackRecipeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'snackRecipeIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snackRecipeIds',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'snackRecipeIds',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snackRecipeIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snackRecipeIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snackRecipeIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snackRecipeIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snackRecipeIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      snackRecipeIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snackRecipeIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      userIdEqualTo(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      userIdLessThan(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      userIdBetween(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      userIdEndsWith(
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

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension DailyMealPlanQueryObject
    on QueryBuilder<DailyMealPlan, DailyMealPlan, QFilterCondition> {}

extension DailyMealPlanQueryLinks
    on QueryBuilder<DailyMealPlan, DailyMealPlan, QFilterCondition> {}

extension DailyMealPlanQuerySortBy
    on QueryBuilder<DailyMealPlan, DailyMealPlan, QSortBy> {
  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByBreakfastPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastPortion', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByBreakfastPortionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastPortion', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByBreakfastRecipeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastRecipeId', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByBreakfastRecipeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastRecipeId', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByDinnerPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerPortion', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByDinnerPortionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerPortion', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByDinnerRecipeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerRecipeId', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByDinnerRecipeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerRecipeId', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByLunchPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchPortion', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByLunchPortionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchPortion', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByLunchRecipeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchRecipeId', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByLunchRecipeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchRecipeId', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> sortByPcosPattern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pcosPattern', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      sortByPcosPatternDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pcosPattern', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension DailyMealPlanQuerySortThenBy
    on QueryBuilder<DailyMealPlan, DailyMealPlan, QSortThenBy> {
  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByBreakfastPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastPortion', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByBreakfastPortionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastPortion', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByBreakfastRecipeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastRecipeId', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByBreakfastRecipeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastRecipeId', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByDinnerPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerPortion', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByDinnerPortionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerPortion', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByDinnerRecipeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerRecipeId', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByDinnerRecipeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerRecipeId', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByLunchPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchPortion', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByLunchPortionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchPortion', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByLunchRecipeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchRecipeId', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByLunchRecipeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchRecipeId', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> thenByPcosPattern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pcosPattern', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy>
      thenByPcosPatternDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pcosPattern', Sort.desc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension DailyMealPlanQueryWhereDistinct
    on QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct> {
  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct>
      distinctByBreakfastPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breakfastPortion');
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct>
      distinctByBreakfastRecipeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breakfastRecipeId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct>
      distinctByDinnerPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dinnerPortion');
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct>
      distinctByDinnerRecipeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dinnerRecipeId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct>
      distinctByLoggedMealTypes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loggedMealTypes');
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct>
      distinctByLunchPortion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lunchPortion');
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct> distinctByLunchRecipeId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lunchRecipeId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct> distinctByPcosPattern(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pcosPattern', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct>
      distinctBySnackRecipeIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snackRecipeIds');
    });
  }

  QueryBuilder<DailyMealPlan, DailyMealPlan, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension DailyMealPlanQueryProperty
    on QueryBuilder<DailyMealPlan, DailyMealPlan, QQueryProperty> {
  QueryBuilder<DailyMealPlan, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyMealPlan, double, QQueryOperations>
      breakfastPortionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breakfastPortion');
    });
  }

  QueryBuilder<DailyMealPlan, String, QQueryOperations>
      breakfastRecipeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breakfastRecipeId');
    });
  }

  QueryBuilder<DailyMealPlan, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyMealPlan, double, QQueryOperations>
      dinnerPortionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dinnerPortion');
    });
  }

  QueryBuilder<DailyMealPlan, String, QQueryOperations>
      dinnerRecipeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dinnerRecipeId');
    });
  }

  QueryBuilder<DailyMealPlan, List<String>, QQueryOperations>
      loggedMealTypesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loggedMealTypes');
    });
  }

  QueryBuilder<DailyMealPlan, double, QQueryOperations> lunchPortionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lunchPortion');
    });
  }

  QueryBuilder<DailyMealPlan, String, QQueryOperations>
      lunchRecipeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lunchRecipeId');
    });
  }

  QueryBuilder<DailyMealPlan, String, QQueryOperations> pcosPatternProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pcosPattern');
    });
  }

  QueryBuilder<DailyMealPlan, List<String>, QQueryOperations>
      snackRecipeIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snackRecipeIds');
    });
  }

  QueryBuilder<DailyMealPlan, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
