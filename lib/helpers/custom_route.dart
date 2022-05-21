import 'package:flutter/material.dart';

/// 画面遷移時のアニメーションの設定を行うクラス
///
/// 個別に設定するようのclass
///
/// ``` dart
/// // 以下のように使用する
///  Navigator.of(context).pushReplacement(
///   CustomRoute(
///     builder: (context) => const OrdersScreen(),
///    ),
/// );
/// ```
class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == "/") {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

/// 画面遷移時のアニメーションの設定を行うクラス
///
/// ページ全体に適応できる
///
/// ``` dart
/// // main.dartのThemeDataで以下のように使用する
/// pageTransitionsTheme: PageTransitionsTheme(builders: {
///             TargetPlatform.android: CustomPageTransitionBuilder(),
///             TargetPlatform.iOS: CustomPageTransitionBuilder(),
///           })),
/// ```
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // NOTE 多分settings.nameを書くがめんチェックすればいろんな画面にいろんなアニメーションを適応できる
    // "/"だけアニメーションを抜く設定
    // if (route.settings.name == "/") {
    //   return child;
    // }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
