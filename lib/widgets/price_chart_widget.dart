import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:crypto_app/services/crypto_api_service.dart';
import 'package:intl/intl.dart';

class PriceChartWidget extends StatefulWidget {
  final String cryptoId;
  final Color lineColor;

  const PriceChartWidget({
    Key? key,
    required this.cryptoId,
    this.lineColor = Colors.blue,
  }) : super(key: key);

  @override
  State<PriceChartWidget> createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends State<PriceChartWidget> {
  final CryptoApiService _apiService = CryptoApiService();
  List<FlSpot> _pricePoints = [];
  bool _isLoading = true;
  String _selectedPeriod = '7';
  double _minY = 0;
  double _maxY = 0;
  DateTime _minX = DateTime.now();
  DateTime _maxX = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _apiService.getHistoricalMarketData(
          widget.cryptoId, int.parse(_selectedPeriod));

      if (data.isEmpty) {
        setState(() {
          _isLoading = false;
          _pricePoints = [];
        });
        return;
      }

      _pricePoints = data.map((point) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(point[0].toInt());
        return FlSpot(
          timestamp.millisecondsSinceEpoch.toDouble(),
          point[1].toDouble(),
        );
      }).toList();

      // Find min and max values
      _minY = _pricePoints.map((point) => point.y).reduce((a, b) => a < b ? a : b);
      _maxY = _pricePoints.map((point) => point.y).reduce((a, b) => a > b ? a : b);

      // Add padding to min and max
      double padding = (_maxY - _minY) * 0.1;
      _minY -= padding;
      _maxY += padding;

      if (_minY < 0) _minY = 0;

      // Find time range
      _minX = DateTime.fromMillisecondsSinceEpoch(
          _pricePoints.first.x.toInt());
      _maxX = DateTime.fromMillisecondsSinceEpoch(
          _pricePoints.last.x.toInt());

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _pricePoints = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.grey[800];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(  // Changed from Row to Column to fix overflow
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
            children: [
              Text(
                'Price Chart',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8), // Add spacing between title and buttons
              SingleChildScrollView( // Wrap SegmentedButton in a scrollable widget
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: '1', label: Text('1D')),
                    ButtonSegment(value: '7', label: Text('7D')),
                    ButtonSegment(value: '30', label: Text('1M')),
                    ButtonSegment(value: '365', label: Text('1Y')),
                  ],
                  selected: {_selectedPeriod},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() {
                      _selectedPeriod = selection.first;
                    });
                    _fetchData();
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pricePoints.isEmpty
                  ? const Center(child: Text('No data available'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '\$${value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final date = DateTime.fromMillisecondsSinceEpoch(
                                      value.toInt());
                                  String text;

                                  if (_selectedPeriod == '1') {
                                    text = DateFormat('HH:mm').format(date);
                                  } else if (_selectedPeriod == '7' || _selectedPeriod == '30') {
                                    text = DateFormat('MM/dd').format(date);
                                  } else {
                                    text = DateFormat('MM/yy').format(date);
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: _pricePoints.first.x,
                          maxX: _pricePoints.last.x,
                          minY: _minY,
                          maxY: _maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _pricePoints,
                              isCurved: true,
                              color: widget.lineColor,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: widget.lineColor.withOpacity(0.2),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              tooltipPadding: const EdgeInsets.all(8),
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final date = DateTime.fromMillisecondsSinceEpoch(
                                      spot.x.toInt());
                                  String formattedDate;

                                  if (_selectedPeriod == '1') {
                                    formattedDate = DateFormat('HH:mm, MMM d').format(date);
                                  } else {
                                    formattedDate = DateFormat('MMM d, yyyy').format(date);
                                  }

                                  return LineTooltipItem(
                                    '$formattedDate\n\$${spot.y.toStringAsFixed(2)}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}