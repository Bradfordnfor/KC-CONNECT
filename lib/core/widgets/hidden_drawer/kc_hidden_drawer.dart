import 'package:flutter/material.dart';
import 'package:kc_connect/core/widgets/hidden_drawer/drawer_items.dart';
import 'package:kc_connect/core/widgets/hidden_drawer/hidden_drawer_menu.dart';

class KcHiddenDrawer extends StatelessWidget {
  const KcHiddenDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenuUI(screens: drawerItems);
  }
}
