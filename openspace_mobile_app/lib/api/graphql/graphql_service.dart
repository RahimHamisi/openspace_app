import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  late GraphQLClient client;

  GraphQLService() {
    final httpLink = HttpLink('http://127.0.0.1:8000/graphql/');

    client = GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
    );
  }

  Future<QueryResult> query(String queryString, {Map<String, dynamic>? variables}) async {
    final options = QueryOptions(
      document: gql(queryString),
      variables: variables ?? {},
    );
    return await client.query(options);
  }

  Future<QueryResult> mutate(String mutationString, {Map<String, dynamic>? variables}) async {
    final options = MutationOptions(
      document: gql(mutationString),
      variables: variables ?? {},
    );
    return await client.mutate(options);
  }
}
