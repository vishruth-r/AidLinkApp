import 'package:aidlink/services/FR_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Your Page'),


      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSlideActionBtn(alertText: "Emergency Alert", bgColor: Colors.red),
            SizedBox(height: 20),
            CustomSlideActionBtn(alertText: "Bleeding Alert", bgColor: Colors.orange),
            SizedBox(height: 20),
            CustomSlideActionBtn(alertText: "Dehydration Alert", bgColor: Colors.blue),
            SizedBox(height: 20),
            CustomSlideActionBtn(alertText: "Social Threat Alert", bgColor: Colors.green),
          ],
        ),
      ),
    );
  }
}

class CustomSlideActionBtn extends StatefulWidget {
  final String alertText;
  final Color bgColor;

  const CustomSlideActionBtn({required this.alertText, required this.bgColor});

  @override
  _CustomSlideActionBtnState createState() => _CustomSlideActionBtnState();
}

class _CustomSlideActionBtnState extends State<CustomSlideActionBtn> {
  final FRServices frServices = FRServices();
  bool _isPerformingAction = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
      },
      onHorizontalDragEnd: (_) async {
        setState(() {
          _isPerformingAction = true;
        });
        FRServices().sendAlert(type: getAlertType(widget.alertText));
        setState(() {
          _isPerformingAction = false;
        });
        int alertType = getAlertType(widget.alertText);
        bool alertRaised = await frServices.sendAlert(type: alertType);
        print("Action completed for ${widget.alertText}");

        if (alertRaised) {
          String snackBarMessage = "Alert raised: ${widget.alertText}";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snackBarMessage),
              duration: Duration(seconds: 2),
            ),
          );

          print("Action completed for ${widget.alertText}");
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Container(
          width: 400,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.bgColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 36,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _isPerformingAction
                        ? const CupertinoActivityIndicator(
                      color: Colors.black,
                    )
                        : const Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  _isPerformingAction ? "Loading..." : widget.alertText,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );


  }
  int getAlertType(String alertText) {
    switch (alertText) {
      case "Emergency Alert":
        return 1;
      case "Bleeding Alert":
        return 2;
      case "Dehydration Alert":
        return 3;
      case "Social Threat Alert":
        return 4;
      default:
        return 0;
    }
  }
}
