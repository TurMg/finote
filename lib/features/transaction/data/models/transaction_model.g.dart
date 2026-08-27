// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTransactionModelCollection on Isar {
  IsarCollection<TransactionModel> get transactionModels => this.collection();
}

const TransactionModelSchema = CollectionSchema(
  name: r'TransactionModel',
  id: -8282894918172491246,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'imagePath': PropertySchema(
      id: 2,
      name: r'imagePath',
      type: IsarType.string,
    ),
    r'inputSource': PropertySchema(
      id: 3,
      name: r'inputSource',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 4,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 5,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 6,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'nominal': PropertySchema(
      id: 7,
      name: r'nominal',
      type: IsarType.double,
    ),
    r'note': PropertySchema(
      id: 8,
      name: r'note',
      type: IsarType.string,
    ),
    r'transactionId': PropertySchema(
      id: 9,
      name: r'transactionId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 10,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _transactionModelEstimateSize,
  serialize: _transactionModelSerialize,
  deserialize: _transactionModelDeserialize,
  deserializeProp: _transactionModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'transactionId': IndexSchema(
      id: 8561542235958051982,
      name: r'transactionId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transactionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _transactionModelGetId,
  getLinks: _transactionModelGetLinks,
  attach: _transactionModelAttach,
  version: '3.1.0+1',
);

int _transactionModelEstimateSize(
  TransactionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.length * 3;
  {
    final value = object.imagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.inputSource.length * 3;
  bytesCount += 3 + object.note.length * 3;
  bytesCount += 3 + object.transactionId.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _transactionModelSerialize(
  TransactionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.imagePath);
  writer.writeString(offsets[3], object.inputSource);
  writer.writeBool(offsets[4], object.isDeleted);
  writer.writeBool(offsets[5], object.isSynced);
  writer.writeDateTime(offsets[6], object.lastUpdated);
  writer.writeDouble(offsets[7], object.nominal);
  writer.writeString(offsets[8], object.note);
  writer.writeString(offsets[9], object.transactionId);
  writer.writeString(offsets[10], object.type);
}

TransactionModel _transactionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TransactionModel();
  object.category = reader.readString(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.id = id;
  object.imagePath = reader.readStringOrNull(offsets[2]);
  object.inputSource = reader.readString(offsets[3]);
  object.isDeleted = reader.readBool(offsets[4]);
  object.isSynced = reader.readBool(offsets[5]);
  object.lastUpdated = reader.readDateTime(offsets[6]);
  object.nominal = reader.readDouble(offsets[7]);
  object.note = reader.readString(offsets[8]);
  object.transactionId = reader.readString(offsets[9]);
  object.type = reader.readString(offsets[10]);
  return object;
}

P _transactionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transactionModelGetId(TransactionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transactionModelGetLinks(TransactionModel object) {
  return [];
}

void _transactionModelAttach(
    IsarCollection<dynamic> col, Id id, TransactionModel object) {
  object.id = id;
}

extension TransactionModelByIndex on IsarCollection<TransactionModel> {
  Future<TransactionModel?> getByTransactionId(String transactionId) {
    return getByIndex(r'transactionId', [transactionId]);
  }

  TransactionModel? getByTransactionIdSync(String transactionId) {
    return getByIndexSync(r'transactionId', [transactionId]);
  }

  Future<bool> deleteByTransactionId(String transactionId) {
    return deleteByIndex(r'transactionId', [transactionId]);
  }

  bool deleteByTransactionIdSync(String transactionId) {
    return deleteByIndexSync(r'transactionId', [transactionId]);
  }

  Future<List<TransactionModel?>> getAllByTransactionId(
      List<String> transactionIdValues) {
    final values = transactionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'transactionId', values);
  }

  List<TransactionModel?> getAllByTransactionIdSync(
      List<String> transactionIdValues) {
    final values = transactionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'transactionId', values);
  }

  Future<int> deleteAllByTransactionId(List<String> transactionIdValues) {
    final values = transactionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'transactionId', values);
  }

  int deleteAllByTransactionIdSync(List<String> transactionIdValues) {
    final values = transactionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'transactionId', values);
  }

  Future<Id> putByTransactionId(TransactionModel object) {
    return putByIndex(r'transactionId', object);
  }

  Id putByTransactionIdSync(TransactionModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'transactionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTransactionId(List<TransactionModel> objects) {
    return putAllByIndex(r'transactionId', objects);
  }

  List<Id> putAllByTransactionIdSync(List<TransactionModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'transactionId', objects, saveLinks: saveLinks);
  }
}

extension TransactionModelQueryWhereSort
    on QueryBuilder<TransactionModel, TransactionModel, QWhere> {
  QueryBuilder<TransactionModel, TransactionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TransactionModelQueryWhere
    on QueryBuilder<TransactionModel, TransactionModel, QWhereClause> {
  QueryBuilder<TransactionModel, TransactionModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterWhereClause>
      transactionIdEqualTo(String transactionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'transactionId',
        value: [transactionId],
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterWhereClause>
      transactionIdNotEqualTo(String transactionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionId',
              lower: [],
              upper: [transactionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionId',
              lower: [transactionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionId',
              lower: [transactionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionId',
              lower: [],
              upper: [transactionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TransactionModelQueryFilter
    on QueryBuilder<TransactionModel, TransactionModel, QFilterCondition> {
  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      dateBetween(
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      imagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      inputSourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      inputSourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inputSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      inputSourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inputSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      inputSourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inputSource',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      inputSourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'inputSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      inputSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'inputSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      inputSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inputSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      inputSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inputSource',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      inputSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputSource',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      inputSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inputSource',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      nominalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nominal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      nominalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nominal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      nominalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nominal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      nominalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nominal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      noteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      transactionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      transactionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      transactionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      transactionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      transactionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'transactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      transactionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'transactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      transactionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'transactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      transactionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'transactionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      transactionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionId',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      transactionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'transactionId',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension TransactionModelQueryObject
    on QueryBuilder<TransactionModel, TransactionModel, QFilterCondition> {}

extension TransactionModelQueryLinks
    on QueryBuilder<TransactionModel, TransactionModel, QFilterCondition> {}

extension TransactionModelQuerySortBy
    on QueryBuilder<TransactionModel, TransactionModel, QSortBy> {
  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByInputSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputSource', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByInputSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputSource', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByNominal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominal', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByNominalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominal', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension TransactionModelQuerySortThenBy
    on QueryBuilder<TransactionModel, TransactionModel, QSortThenBy> {
  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByInputSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputSource', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByInputSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputSource', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByNominal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominal', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByNominalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominal', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension TransactionModelQueryWhereDistinct
    on QueryBuilder<TransactionModel, TransactionModel, QDistinct> {
  QueryBuilder<TransactionModel, TransactionModel, QDistinct>
      distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QDistinct>
      distinctByImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QDistinct>
      distinctByInputSource({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputSource', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QDistinct>
      distinctByNominal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nominal');
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QDistinct>
      distinctByTransactionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionModel, TransactionModel, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension TransactionModelQueryProperty
    on QueryBuilder<TransactionModel, TransactionModel, QQueryProperty> {
  QueryBuilder<TransactionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TransactionModel, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<TransactionModel, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<TransactionModel, String?, QQueryOperations>
      imagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePath');
    });
  }

  QueryBuilder<TransactionModel, String, QQueryOperations>
      inputSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputSource');
    });
  }

  QueryBuilder<TransactionModel, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<TransactionModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<TransactionModel, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<TransactionModel, double, QQueryOperations> nominalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nominal');
    });
  }

  QueryBuilder<TransactionModel, String, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<TransactionModel, String, QQueryOperations>
      transactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionId');
    });
  }

  QueryBuilder<TransactionModel, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
