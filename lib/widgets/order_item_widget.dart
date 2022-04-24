import 'package:flutter/material.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:intl/intl.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderItem order;
  const OrderItemWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text("\$${order.amount}"),
            subtitle: Text(
              DateFormat("yyyy/MM/dd hh:mm").format(order.dateTime),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.expand),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
