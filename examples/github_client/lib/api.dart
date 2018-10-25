import 'dart:async';
import 'package:async/async.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const baseUrl = 'api.github.com';
const searchUrl = '/search/repositories';
const trendingUrl = '/trending';

enum TrendingPeriod { daily, weekly, monthly }

///Shared httpClient, used for all requests
final _client = http.Client();

///Function for fetching trending repositories list
Future<SearchResult> fetchTrendingRepos({Language forLanguage, TrendingPeriod forPeriod = TrendingPeriod.weekly,}) async {
  final response = await _client.get(
    _trendingUrl(forPeriod, forLanguage == Language.All ? null : forLanguage),
  );
  if (response.statusCode == 200) {
    return SearchResult.fromJson(json.decode(response.body));
  }
  throw Exception('failed to load trending repos');
}

///Wrapper around [Future] for request cancellation
CancelableOperation _lastFetchRequest;

///Function for searching repositories by query.
///If we try to send request while previous is still pending,
///then previous is canceled.
Future<SearchResult> fetchReposByQuery(String query) async {
  _lastFetchRequest?.cancel();

  final fetchFuture = _client.get(_searchUrl(query));

  _lastFetchRequest = CancelableOperation.fromFuture(fetchFuture);

  final response = await _lastFetchRequest.valueOrCancellation(null);
  _lastFetchRequest = null;
  if (response != null && response.statusCode == 200) {
    return SearchResult.fromJson(json.decode(response.body));
  }
  throw Exception('failed to load trending repos');
}

///Function for getting readme content for specified repository
Future<String> fetchReadmeFor(GitHubRepository repo) async {
  final rawUrl =
      'https://raw.githubusercontent.com/${repo.fullName}/master/README.md';
  final response = await _client.get(rawUrl);
  if (response.statusCode == 200) {
    return response.body;
  }
  throw Exception('failed to load Readme for ${repo.fullName}');
}

Uri _trendingUrl(TrendingPeriod period, Language language) {
  final langQuery = language != null ? '&q=language:${language.name}' : '';
  final uri =
      'https://$baseUrl$searchUrl?q=created:>${_formattedDate(period)}$langQuery&sort=stars&order=desc&page=0&per_page=50';
  return Uri.parse(uri);
}

final _dateFormat = DateFormat('yyyy-MM-dd', null);
String _formattedDate(TrendingPeriod period) {
  final date = DateTime.now().subtract(Duration(days: _periodToDaysCount(period)));
  return _dateFormat.format(date);
}

int _periodToDaysCount(TrendingPeriod period) {
  switch (period) {
    case TrendingPeriod.daily: return 1;
    case TrendingPeriod.weekly: return 7;
    case TrendingPeriod.monthly: return 30;
    default: return 7;
  }
}

Uri _searchUrl(String query) {
  return Uri.https(baseUrl, searchUrl, {
    'q': '$query',
    'sort': 'stars',
    'order': 'desc',
    'page': '0',
    'per_page': '50'
  });
}

///DTO's for GitHub API
class SearchResult {
  final int totalCount;
  final bool incompleteResults;
  final List<GitHubRepository> items;

  SearchResult({this.totalCount, this.incompleteResults, this.items});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      totalCount: json['total_count'],
      incompleteResults: json['incomplete_results'],
      items: json['items']
          .map((x) => GitHubRepository.fromJson(x))
          .cast<GitHubRepository>()
          .toList(),
    );
  }
}

class GitHubRepository {
  final int id;
  final String name;
  final String fullName;
  final Uri htmlUrl;
  final String description;
  final Uri apiUrl;
  int stargazersCount;
  final int watchersCount;
  final int forksCount;
  final String language;
  final double score;
  final Owner owner;

  GitHubRepository({
    this.id,
    this.name,
    this.fullName,
    this.htmlUrl,
    this.description,
    this.apiUrl,
    this.stargazersCount,
    this.watchersCount,
    this.forksCount,
    this.language,
    this.score,
    this.owner,
  });

  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    return GitHubRepository(
      id: json['id'],
      name: json['name'],
      fullName: json['full_name'],
      htmlUrl: Uri.parse(json['html_url']),
      description: json['description'],
      apiUrl: Uri.parse(json['url']),
      stargazersCount: json['stargazers_count'],
      watchersCount: json['watchers_count'],
      forksCount: json['forks_count'],
      language: json['language'],
      score: json['score'],
      owner: Owner.fromJson(json['owner']),
    );
  }

  @override
  bool operator ==(other) {
    if (other == null) return false;
    return this.id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Owner {
  final int id;
  final String login;
  final Uri avatar;

  Owner({this.id, this.login, this.avatar});
  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      login: json['login'],
      avatar: Uri.parse(json['avatar_url']),
    );
  }
}


List<Language> _languagesCache;
///Function for loading predefined languages list from json file in assets.
///Used for filter and coloring in list.
Future<List<Language>> getLanguages() async {
  if (_languagesCache != null) {
    return _languagesCache;
  }
  final jsonStr =
      await rootBundle.loadString('assets/langs.json', cache: false);
  final List<Map<String, dynamic>> jsonMap =
      json.decode(jsonStr).cast<Map<String, dynamic>>();
  _languagesCache =
      jsonMap.map((x) => Language.fromJson(x)).toList(growable: false);
  return _languagesCache;
}

Map<String, Language> _languagesByNameCache;
///The same as [getLanguages] but returned as [Map] by [Language.name]
Future<Map<String, Language>> getLanguagesByNameMap() async {
  if (_languagesByNameCache != null) {
    return _languagesByNameCache;
  }
  final langList = await getLanguages();
  _languagesByNameCache = Map.fromIterable(langList, key: (x)=>x.displayName, value: (x)=>x);
  return _languagesByNameCache;
}

class Language {
  final String name;
  final String displayName;
  final int color;

  const Language({
    this.name,
    this.color,
    this.displayName,
  });
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'],
      displayName: json['display_name'] ?? json['name'],
      color: int.parse('ff' + json['color'], radix: 16),
    );
  }

  static const All = Language(name: 'all', displayName: 'all', color: 0xFFFFFFFF);
}
