import '../../library.dart';

class StallBalance {
  final num value;
  const StallBalance(this.value);
}

class AccountPage extends StatefulWidget {
  const AccountPage({Key key}) : super(key: key);
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeNotifier>(context);
    final stallBalance = Provider.of<StallBalance>(context).value;
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: context.windowSize.height,
        ),
        child: Padding(
          padding: context.windowPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: context.theme.hintColor,
                          child: Center(
                            child: Text(
                              'J',
                              style: TextStyle(
                                fontSize: 32,
                                color: context.theme.canvasColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                          width: double.infinity,
                        ),
                        Text(
                          'Japanese Stall',
                          style: context.theme.textTheme.body2,
                        ),
                        Text(
                          '86937538',
                          style: context.theme.textTheme.caption,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          'Balance',
                          style: context.theme.textTheme.subtitle,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        CustomAnimatedSwitcher(
                          child: Text(
                            '\$${stallBalance.toStringAsFixed(2)}',
                            key: ValueKey(stallBalance),
                            style: context.theme.textTheme.display1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const SizedBox.shrink(),
                    IconButton(
                      color: Theme.of(context).hintColor,
                      icon: CustomAnimatedSwitcher(
                        child: Icon(
                          themeModel.isDarkMode
                              ? Icons.brightness_2
                              : Icons.brightness_6,
                          key: ValueKey(themeModel.isDarkMode),
                        ),
                      ),
                      tooltip: 'Change Theme',
                      onPressed: () {
                        themeModel.isDarkMode = !themeModel.isDarkMode;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
