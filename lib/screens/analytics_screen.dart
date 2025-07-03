import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  final String userId;
  const AnalyticsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, Map<String, double>> _monthlyTypeTotals = {}; // {month: {type: total}}
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyTotals();
  }

  Future<void> _fetchMonthlyTotals() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transaction')
        .where('user_id', isEqualTo: widget.userId)
        .get();

    Map<String, Map<String, double>> monthlyTypeTotals = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('amount') &&
          data.containsKey('date_time') &&
          data.containsKey('transaction_type')) {
        final amount = (data['amount'] as num).toDouble();
        final timestamp = data['date_time'];
        final type = data['transaction_type'] ?? 'Other';
        DateTime? date;
        if (timestamp is Timestamp) {
          date = timestamp.toDate();
        } else if (timestamp is DateTime) {
          date = timestamp;
        }
        if (date != null &&
            (type == 'Deposit' || type == 'Transfer')) {
          final monthKey = DateFormat('yyyy-MM').format(date);
          monthlyTypeTotals[monthKey] ??= {'Deposit': 0, 'Transfer': 0};
          monthlyTypeTotals[monthKey]![type] =
              (monthlyTypeTotals[monthKey]![type] ?? 0) + amount;
        }
      }
    }
    setState(() {
      _monthlyTypeTotals = monthlyTypeTotals;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = _monthlyTypeTotals.keys.toList()..sort();
    final allValues = _monthlyTypeTotals.values.expand((map) => map.values);
    final maxAmount =
    allValues.isNotEmpty ? allValues.reduce((a, b) => a > b ? a : b) : 0.0;
    double interval = 500;
    if (maxAmount <= 500) {
      interval = 100;
    } else if (maxAmount <= 2000) {
      interval = 200;
    }
    double maxY = ((maxAmount / interval).ceil() * interval).toDouble();
    if (maxY == 0) {
      interval = maxY = 500;
    }

    // Calculate total deposit/transfer across all months
    final totalDeposit = _monthlyTypeTotals.values
        .fold(0.0, (sum, map) => sum + (map['Deposit'] ?? 0));
    final totalTransfer = _monthlyTypeTotals.values
        .fold(0.0, (sum, map) => sum + (map['Transfer'] ?? 0));
    final netFlow = totalDeposit - totalTransfer;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Monthly Transactions'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Monthly Total Amount',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 220,
                            width: 320,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  handleBuiltInTouches: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipPadding: const EdgeInsets.all(8),
                                    tooltipMargin: 8,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      final month = sortedKeys[group.x];
                                      final type = rodIndex == 0
                                          ? 'Deposit'
                                          : 'Transfer';
                                      return BarTooltipItem(
                                        "$month $type: ₱${rod.toY.toStringAsFixed(2)}",
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, _) {
                                        int index = value.toInt();
                                        if (index < 0 ||
                                            index >= sortedKeys.length) {
                                          return const SizedBox();
                                        }
                                        final month = sortedKeys[index];
                                        return Text(
                                          DateFormat('MMM').format(
                                              DateTime.parse(month + "-01")),
                                          style:
                                          const TextStyle(fontSize: 12),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: interval,
                                      getTitlesWidget: (value, _) => Text(
                                          "₱${value.toInt()}",
                                          style:
                                          const TextStyle(fontSize: 11)),
                                      reservedSize: 50,
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                      sideTitles:
                                      SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(
                                      sideTitles:
                                      SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawHorizontalLine: true,
                                  horizontalInterval: interval,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.grey.shade300,
                                    strokeWidth: 1,
                                  ),
                                  drawVerticalLine: false,
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(sortedKeys.length,
                                        (i) {
                                      final month = sortedKeys[i];
                                      final deposit =
                                          _monthlyTypeTotals[month]?['Deposit'] ??
                                              0;
                                      final transfer =
                                          _monthlyTypeTotals[month]?['Transfer'] ??
                                              0;
                                      return BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: deposit,
                                            width: 16,
                                            borderRadius: BorderRadius.circular(6),
                                            color: Colors.teal,
                                          ),
                                          BarChartRodData(
                                            toY: transfer,
                                            width: 16,
                                            borderRadius: BorderRadius.circular(6),
                                            color: Colors.orange,
                                          ),
                                        ],
                                        barsSpace: 8,
                                      );
                                    }),
                                maxY: maxY,
                                groupsSpace: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Icon(Icons.bar_chart, color: Colors.teal),
                              SizedBox(width: 6),
                              Text(
                                "Total ₱ amount per month",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black87),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.square,
                                  color: Colors.teal, size: 16),
                              Text(' Deposit  '),
                              Icon(Icons.square,
                                  color: Colors.orange, size: 16),
                              Text(' Transfer'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.compare_arrows,
                                  color: Colors.purple),
                              const SizedBox(width: 8),
                              Text(
                                'Net Flow: ₱${netFlow.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: netFlow >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
