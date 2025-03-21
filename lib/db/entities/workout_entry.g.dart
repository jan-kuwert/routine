// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutEntryCollection on Isar {
  IsarCollection<WorkoutEntry> get workoutEntrys => this.collection();
}

const WorkoutEntrySchema = CollectionSchema(
  name: r'WorkoutEntry',
  id: -2682324398368231174,
  properties: {
    r'counter': PropertySchema(
      id: 0,
      name: r'counter',
      type: IsarType.long,
    ),
    r'created': PropertySchema(
      id: 1,
      name: r'created',
      type: IsarType.dateTime,
    ),
    r'goal': PropertySchema(
      id: 2,
      name: r'goal',
      type: IsarType.long,
    ),
    r'updated': PropertySchema(
      id: 3,
      name: r'updated',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _workoutEntryEstimateSize,
  serialize: _workoutEntrySerialize,
  deserialize: _workoutEntryDeserialize,
  deserializeProp: _workoutEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'counter': IndexSchema(
      id: 5395096269862819869,
      name: r'counter',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'counter',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'workout': LinkSchema(
      id: -6072340514792738630,
      name: r'workout',
      target: r'Workout',
      single: false,
    ),
    r'exercise': LinkSchema(
      id: 8229583333684219189,
      name: r'exercise',
      target: r'Exercise',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _workoutEntryGetId,
  getLinks: _workoutEntryGetLinks,
  attach: _workoutEntryAttach,
  version: '3.1.0+1',
);

int _workoutEntryEstimateSize(
  WorkoutEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _workoutEntrySerialize(
  WorkoutEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.counter);
  writer.writeDateTime(offsets[1], object.created);
  writer.writeLong(offsets[2], object.goal);
  writer.writeDateTime(offsets[3], object.updated);
}

WorkoutEntry _workoutEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutEntry();
  object.counter = reader.readLong(offsets[0]);
  object.created = reader.readDateTime(offsets[1]);
  object.goal = reader.readLong(offsets[2]);
  object.id = id;
  object.updated = reader.readDateTime(offsets[3]);
  return object;
}

P _workoutEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutEntryGetId(WorkoutEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutEntryGetLinks(WorkoutEntry object) {
  return [object.workout, object.exercise];
}

void _workoutEntryAttach(
    IsarCollection<dynamic> col, Id id, WorkoutEntry object) {
  object.id = id;
  object.workout.attach(col, col.isar.collection<Workout>(), r'workout', id);
  object.exercise.attach(col, col.isar.collection<Exercise>(), r'exercise', id);
}

extension WorkoutEntryQueryWhereSort
    on QueryBuilder<WorkoutEntry, WorkoutEntry, QWhere> {
  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhere> anyCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'counter'),
      );
    });
  }
}

extension WorkoutEntryQueryWhere
    on QueryBuilder<WorkoutEntry, WorkoutEntry, QWhereClause> {
  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhereClause> counterEqualTo(
      int counter) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'counter',
        value: [counter],
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhereClause> counterNotEqualTo(
      int counter) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'counter',
              lower: [],
              upper: [counter],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'counter',
              lower: [counter],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'counter',
              lower: [counter],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'counter',
              lower: [],
              upper: [counter],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhereClause>
      counterGreaterThan(
    int counter, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'counter',
        lower: [counter],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhereClause> counterLessThan(
    int counter, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'counter',
        lower: [],
        upper: [counter],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterWhereClause> counterBetween(
    int lowerCounter,
    int upperCounter, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'counter',
        lower: [lowerCounter],
        includeLower: includeLower,
        upper: [upperCounter],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutEntryQueryFilter
    on QueryBuilder<WorkoutEntry, WorkoutEntry, QFilterCondition> {
  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      counterEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'counter',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      counterGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'counter',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      counterLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'counter',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      counterBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'counter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      createdEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'created',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      createdGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'created',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      createdLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'created',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      createdBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'created',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition> goalEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goal',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      goalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goal',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition> goalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goal',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition> goalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      updatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updated',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      updatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updated',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      updatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updated',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      updatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutEntryQueryObject
    on QueryBuilder<WorkoutEntry, WorkoutEntry, QFilterCondition> {}

extension WorkoutEntryQueryLinks
    on QueryBuilder<WorkoutEntry, WorkoutEntry, QFilterCondition> {
  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition> workout(
      FilterQuery<Workout> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'workout');
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      workoutLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'workout', length, true, length, true);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      workoutIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'workout', 0, true, 0, true);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      workoutIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'workout', 0, false, 999999, true);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      workoutLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'workout', 0, true, length, include);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      workoutLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'workout', length, include, 999999, true);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      workoutLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'workout', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition> exercise(
      FilterQuery<Exercise> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'exercise');
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterFilterCondition>
      exerciseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercise', 0, true, 0, true);
    });
  }
}

extension WorkoutEntryQuerySortBy
    on QueryBuilder<WorkoutEntry, WorkoutEntry, QSortBy> {
  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> sortByCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'counter', Sort.asc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> sortByCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'counter', Sort.desc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> sortByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.asc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> sortByCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.desc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> sortByGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.asc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> sortByGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.desc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> sortByUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updated', Sort.asc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> sortByUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updated', Sort.desc);
    });
  }
}

extension WorkoutEntryQuerySortThenBy
    on QueryBuilder<WorkoutEntry, WorkoutEntry, QSortThenBy> {
  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> thenByCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'counter', Sort.asc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> thenByCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'counter', Sort.desc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> thenByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.asc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> thenByCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.desc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> thenByGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.asc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> thenByGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.desc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> thenByUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updated', Sort.asc);
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QAfterSortBy> thenByUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updated', Sort.desc);
    });
  }
}

extension WorkoutEntryQueryWhereDistinct
    on QueryBuilder<WorkoutEntry, WorkoutEntry, QDistinct> {
  QueryBuilder<WorkoutEntry, WorkoutEntry, QDistinct> distinctByCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'counter');
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QDistinct> distinctByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'created');
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QDistinct> distinctByGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goal');
    });
  }

  QueryBuilder<WorkoutEntry, WorkoutEntry, QDistinct> distinctByUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updated');
    });
  }
}

extension WorkoutEntryQueryProperty
    on QueryBuilder<WorkoutEntry, WorkoutEntry, QQueryProperty> {
  QueryBuilder<WorkoutEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutEntry, int, QQueryOperations> counterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'counter');
    });
  }

  QueryBuilder<WorkoutEntry, DateTime, QQueryOperations> createdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'created');
    });
  }

  QueryBuilder<WorkoutEntry, int, QQueryOperations> goalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goal');
    });
  }

  QueryBuilder<WorkoutEntry, DateTime, QQueryOperations> updatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updated');
    });
  }
}
