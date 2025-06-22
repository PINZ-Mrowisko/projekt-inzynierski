import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/confirmation_dialog.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';
import 'package:the_basics/utils/common_widgets/search_bar.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = ignoreOverflowErrors;

  testWidgets('BaseDialog renders with child and close button', (WidgetTester tester) async {
    bool wasClosed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BaseDialog(
                      width: 300,
                      showCloseButton: true,
                      child: const Text('Hello World'),
                    ),
                  ).then((_) => wasClosed = true);
                },
                child: const Text('Open Dialog'),
              ),
            );
          },
        ),
      ),
    );

    // we open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Hello World'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    // lets tap the close icon
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Hello World'), findsNothing);
    expect(wasClosed, isTrue);
  });

  testWidgets('ConfirmationDialog displays correctly and reacts to buttons', (WidgetTester tester) async {
    bool confirmCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: 'Delete item?',
                      subtitle: 'This action cannot be undone.',
                      confirmText: 'Yes',
                      cancelText: 'No',
                      onConfirm: () {
                        confirmCalled = true;
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    // tap button to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // check texts
    expect(find.text('Delete item?'), findsOneWidget);
    expect(find.text('This action cannot be undone.'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);

    // tap Cancel button
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    // dialog should now be gone 4ever
    expect(find.text('Delete item?'), findsNothing);
    expect(confirmCalled, isFalse);

    // lets reopen!
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.text('Delete item?'), findsNothing);
    expect(confirmCalled, isTrue);
  });

  testWidgets('CustomButton renders with text and triggers onPressed', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Click Me',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    // check if text is rendered
    expect(find.text('Click Me'), findsOneWidget);

    // and click
    await tester.tap(find.text('Click Me'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('CustomButton renders icon when provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'With Icon',
            icon: Icons.add,
            onPressed: () {},
          ),
        ),
      ),
    );

    // check text
    expect(find.text('With Icon'), findsOneWidget);

    // and icon
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  group('GenericList', () {
    late List<String> items;
    late List<String> tappedItems;
    late List<String> longPressedItems;

    setUp(() {
      items = ['Item 1', 'Item 2', 'Item 3'];
      tappedItems = [];
      longPressedItems = [];
    });

    Widget buildTestWidget({
      void Function(String)? onTap,
      void Function(String)? onLongPress,
      Color? backgroundColor,
      Color? hoverColor,
      Color? splashColor,
      double? borderRadius,
      EdgeInsets? margin,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GenericList<String>(
            items: items,
            itemBuilder: (context, item) => ListTile(title: Text(item)),
            onItemTap: onTap,
            onItemLongPress: onLongPress,
            itemBackgroundColor: backgroundColor,
            hoverColor: hoverColor,
            splashColor: splashColor,
            itemBorderRadius: borderRadius,
            itemMargin: margin,
          ),
        ),
      );
    }

    testWidgets('renders all items correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      for (final item in items) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets('calls onItemTap when tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        onTap: (item) => tappedItems.add(item),
      ));

      await tester.tap(find.text('Item 2'));
      await tester.pump();

      expect(tappedItems, contains('Item 2'));
    });

    testWidgets('calls onItemLongPress when long-pressed', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        onLongPress: (item) => longPressedItems.add(item),
      ));

      await tester.longPress(find.text('Item 3'));
      await tester.pump();

      expect(longPressedItems, contains('Item 3'));
    });


    testWidgets('renders empty list correctly', (tester) async {
      items = [];

      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('uses default hover and splash colors when not provided', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final materialInkWell = tester.widget<InkWell>(
        find.descendant(of: find.byType(GenericList<String>), matching: find.byType(InkWell)).first,
      );

      expect(materialInkWell.hoverColor, AppColors.lightBlue);
      expect(materialInkWell.splashColor, AppColors.lightBlue);
    });

    testWidgets('uses custom hover and splash colors', (tester) async {
      const hoverColor = Colors.green;
      const splashColor = Colors.orange;

      await tester.pumpWidget(buildTestWidget(
        hoverColor: hoverColor,
        splashColor: splashColor,
      ));

      final materialInkWell = tester.widget<InkWell>(
        find.descendant(of: find.byType(GenericList<String>), matching: find.byType(InkWell)).first,
      );

      expect(materialInkWell.hoverColor, hoverColor);
      expect(materialInkWell.splashColor, splashColor);
    });
  });

  group('Search bar', () {
    testWidgets('CustomSearchBar renders with default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomSearchBar(),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);

      expect(find.byIcon(Icons.search), findsOneWidget);

      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('CustomSearchBar displays custom hintText', (WidgetTester tester) async {
      const hint = 'Wyszukaj pracownika';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomSearchBar(hintText: hint),
          ),
        ),
      );

      expect(find.text(hint), findsOneWidget);
    });

    testWidgets('CustomSearchBar calls onChanged when text changes', (WidgetTester tester) async {
      String typedText = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSearchBar(
              onChanged: (text) {
                typedText = text;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      expect(typedText, 'Test');
    });

  });
}