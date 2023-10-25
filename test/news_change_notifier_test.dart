import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';

// 4. Create MockNewsService class for step 3 below. - We're not using this, this is just
// the most basic and not a good way and written for revising the basic concepts.
class MockNewsService implements NewsService {
  bool areArticledCalled = false;

  @override
  Future<List<Article>> getArticles() async {
    areArticledCalled = true;
    return [
      Article(title: 'Test 1', content: 'Test 1 content'),
      Article(title: 'Test 2', content: 'Test 2 content'),
      Article(title: 'Test 3', content: 'Test 3 content'),
      Article(title: 'Test 4', content: 'Test 4 content'),
      Article(title: 'Test 5', content: 'Test 5 content'),
    ];
  }
}

// 5. We don't have to write the step 4 class, instead we can use the mocktail package which is more effecient
class MockNewsServiceEfficient extends Mock implements NewsService {}
//

void main() {
  // 1. Create an instance of the Change Notifier
  late NewsChangeNotifier sut; // sut- System under test, it's called
  //sut because we're basically testing this class under test

  // 6. create a mock MockNewsServiceEfficient var
  late MockNewsServiceEfficient mockNewsService; // assign in setup method

  // 2. Create the setup method
  // This setup method runs before each and every test
  setUp(() {
    // 8. Assign the value to the mockNewsService
    mockNewsService = MockNewsServiceEfficient();

    // 3. Set sut to a NewsChangeNotifier
    // Here we can't use - sut = NewsChangeNotifier(NewsService());, because it can cause test flakiness, in which
    // our code doesn't have any error but the server from where we're fetching the data might cause error sometimes.

    sut = NewsChangeNotifier(mockNewsService);
  });

  // 9. Create the test cases NOW
  test(
    "initial values are correct",
    () {
      // Initially our articles list is empty - check that
      expect(sut.articles, []);
      // Initially our isLoadin is false - check that
      expect(sut.isLoading, false);
    },
  );

  // 10. TEST FOR THE NEWS getArticles Method
  // Whenever we'll test methods, use group((){}) for test - #recommended
  //
  group(
    'getArticles',
    () {
      // articls from service
      final articlesFromService = [
        Article(title: 'Test 1', content: 'Test 1 content'),
        Article(title: 'Test 2', content: 'Test 2 content'),
        Article(title: 'Test 3', content: 'Test 3 content'),
        Article(title: 'Test 4', content: 'Test 4 content'),
        Article(title: 'Test 5', content: 'Test 5 content'),
      ];
      void arrangeNewsServiceReturns3Articles() {
        when(() => mockNewsService.getArticles())
            .thenAnswer((_) async => articlesFromService);
      }

      // 11. Write all the tests

      // TEST - 1
      test(
        'get articles using the NewsService',
        () async {
          arrangeNewsServiceReturns3Articles();
          when(() => mockNewsService.getArticles()).thenAnswer((_) async => []);

          await sut.getArticles();
          verify(() => mockNewsService.getArticles()).called(
              1); // verifying that the getArticles method called only 1 time from the mockNewsService
        },
      );

      // TEST - 2, data loaded or not
      test('''indicate loading of data, 
          set articles to the ones from the service,
          indicate data is not loading anymore.''', () async {
        arrangeNewsServiceReturns3Articles();

        // Test calling getArticles indicates loading of data
        final future = sut.getArticles();
        expect(sut.isLoading, true);
        await future;

        // check articles are the ones from the service
        expect(sut.articles, articlesFromService);

        expect(sut.isLoading, false);
      });
    },
  );
}
