import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frets/src/marker.dart';

final String sharp = String.fromCharCode((0x268D));
final String natural = String.fromCharCode((0x267D));
final String flat = String.fromCharCode((0x266));

/// The Frets widget is used to display a fretboard with markers for chords.
class Frets extends StatelessWidget {
  const Frets(
      {super.key,
      this.markerSize,
      this.height = 200,
      this.width = 200,
      this.padding = const EdgeInsets.all(8.0),
      this.strings = 6,
      this.frets = 4,
      required this.root,
      this.extension = "",
      required this.markers,
      this.markerColor = Colors.black,
      this.markerTextColor = Colors.white,
      this.startFret,
      this.openMarkers,
      this.borderColor = Colors.black,
      this.borderSize = 0,
      this.headerSize = 25,
      this.fontFamily = "packages/frets/MuseJazzText"});

  /// Widget Height
  final int height;
  /// Widget Width
  final int width;
  /// Padding around the widget
  final EdgeInsets padding;
  /// Number of strings
  final int strings;
  /// The fret number that the first fret should be displayed as  
  final int? startFret;
  /// Number of frets
  final int frets;
  /// The root note of the chord
  final String root;
  /// The chord extension in superscript
  final String extension;
  /// The size of the header text
  final double headerSize;
  /// The markers to display on the top of the fretboard
  final List<Marker?>? openMarkers;
  /// The markers to display on the fretboard
  final List<List<Marker?>> markers;
  /// The default size of the markers
  final int? markerSize;
  /// The default color of the markers
  final Color markerColor;
  /// The default text color of the markers
  final Color markerTextColor;
  /// The default border color of the markers
  final Color borderColor;
  /// The default border size of the markers
  final int borderSize;
  /// The default font family to use for the text
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width.toDouble(), height.toDouble()),
      painter: FretPainter(this),
    );
  }
}

class FretPainter extends CustomPainter {
  FretPainter(this.parent);

  final Frets parent;

  @override
  void paint(Canvas canvas, Size size) {
    final mainTextSpan = TextSpan(
      text: parent.root,
      style: TextStyle(
          fontSize: parent.headerSize,
          color: Colors.black,
          fontFamily: parent.fontFamily),
    );

    final superscriptSpan = TextSpan(
      text: parent.extension,
      style: TextStyle(
          fontSize: parent.headerSize / 2,
          height: 2,
          color: Colors.black,
          fontFamily: parent.fontFamily),
    );

    final mainPainter = TextPainter(
      text: mainTextSpan,
      textDirection: TextDirection.ltr,
    );

    final superPainter = TextPainter(
      text: superscriptSpan,
      textDirection: TextDirection.ltr,
    );

    mainPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    superPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    var headerSpacing = (mainPainter.height / 2 + superPainter.height / 2) +
        (parent.openMarkers != null ? 10 : 0);
    var sideSpacing =
        (size.width - (parent.padding.left + parent.padding.right)) /
            (parent.strings + 2);
    var fbPadding = parent.padding.copyWith(
        top: parent.padding.top + headerSpacing,
        left: parent.padding.left + sideSpacing,
        right: parent.padding.right + sideSpacing);

    var drawWidth = (size.width - fbPadding.left - fbPadding.right);
    var drawHeight = (size.height - fbPadding.top - fbPadding.bottom);
    var stringSpacing = drawWidth / (parent.strings - 1);
    var fretSpacing = drawHeight / (parent.frets);

    double shapeRadius = (parent.markerSize ?? stringSpacing * .45) as double;
    mainPainter.paint(
      canvas,
      Offset((size.width - mainPainter.width - superPainter.width) / 2, -10),
    );
    superPainter.paint(
      canvas,
      Offset((size.width - superPainter.width + mainPainter.width) / 2, -15),
    );

    for (var i = 0; i < parent.strings; i++) {
      canvas.drawLine(
          Offset(fbPadding.left + (stringSpacing * i), fbPadding.top),
          Offset(fbPadding.left + (stringSpacing * i),
              size.height - fbPadding.bottom),
          Paint());
    }

    for (var i = 0; i <= parent.frets; i++) {
      var p = parent.startFret == null && i == 0
          ? (Paint()..strokeWidth = 5)
          : (Paint()..strokeWidth = 1);
      canvas.drawLine(
          Offset(fbPadding.left, fbPadding.top + (fretSpacing * i)),
          Offset(
              size.width - fbPadding.right, fbPadding.top + (fretSpacing * i)),
          p);
    }

    if (parent.startFret != null) {
      drawString(
          canvas,
          size,
          Offset(fbPadding.left - sideSpacing, fbPadding.top + fretSpacing / 2),
          parent.startFret.toString(),
          20,
          Colors.black,
          parent.fontFamily);
    }

    if (parent.openMarkers != null) {
      for (var i = 0; i < parent.openMarkers!.length; i++) {
        if (i >= parent.strings) {
          break;
        }
        if (parent.openMarkers![i] == null) {
          continue;
        }
        Marker marker = parent.openMarkers![i] as Marker;

        var x = fbPadding.left + (stringSpacing * i);
        var y = fbPadding.top - 15;

        Color bgColor = marker?.bgColor ?? parent.markerColor;
        Color txtColor = marker?.textColor ?? parent.markerTextColor;
        Color brdColor = marker?.borderColor ?? parent.borderColor;
        double radius = marker?.radius as double? ?? shapeRadius;
        double borderSize = (marker?.borderSize ?? parent.borderSize) as double;

        drawMarker(marker, canvas, x, y, radius, bgColor, borderSize, brdColor,
            size, txtColor);

        // drawString(canvas, size, Offset(x, y), parent.openMarkers![i],
        //     shapeRadius * 1.25, parent.markerColor, parent.fontFamily);
      }
    }

    for (var i = 0; i < parent.markers.length; i++) {
      if (i >= parent.frets) {
        break;
      }

      for (var j = 0; j < parent.markers[i].length; j++) {
        if (j >= parent.strings) {
          break;
        }
        if (parent.markers[i][j] == null) {
          continue;
        }

        var marker = parent.markers[i][j];
        var x = fbPadding.left + (stringSpacing * j);
        var y = fbPadding.top + (fretSpacing * i) + fretSpacing / 2;

        Color bgColor = marker!.bgColor ?? parent.markerColor;
        Color txtColor = marker.textColor ?? parent.markerTextColor;
        Color brdColor = marker.borderColor ?? parent.borderColor;
        double radius = marker.radius as double? ?? shapeRadius;
        double borderSize = (marker.borderSize ?? parent.borderSize) as double;

        double barreLength = (marker.shape == MarkerShape.barre)
            ?   
            marker.barreLength == null
                ? (parent.strings - j - 1) * stringSpacing:
                min((marker.barreLength! -1) * stringSpacing, (parent.strings - j - 1) * stringSpacing)
              
            : 0;

        drawMarker(marker, canvas, x, y, radius, bgColor, borderSize, brdColor,
            size, txtColor,
            barreLength: barreLength);
      }
    }

    // canvas.drawRect(
    //     Rect.fromLTRB(0, 0, size.width, size.height),
    //     Paint()
    //       ..style = PaintingStyle.stroke
    //       ..color = Colors.black);
  }

  void drawMarker(
      Marker marker,
      ui.Canvas canvas,
      double x,
      double y,
      double radius,
      ui.Color bgColor,
      double borderSize,
      ui.Color brdColor,
      ui.Size size,
      ui.Color txtColor,
      {double barreLength = 0}) {
    switch (marker.shape ?? MarkerShape.circle) {
      case MarkerShape.circle:
        canvas.drawCircle(Offset(x, y), radius, Paint()..color = bgColor);
        if (borderSize > 0) {
          canvas.drawCircle(
              Offset(x, y),
              radius,
              Paint()
                ..color = brdColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = borderSize);
        }

        break;
      case MarkerShape.triangle:
        canvas.drawPath(
            Path()
              ..moveTo(x, y - radius)
              ..lineTo(x + radius, y + radius)
              ..lineTo(x - radius, y + radius)
              ..close(),
            Paint()..color = bgColor);
        if (borderSize > 0) {
          canvas.drawPath(
              Path()
                ..moveTo(x, y - radius)
                ..lineTo(x + radius, y + radius)
                ..lineTo(x - radius, y + radius)
                ..close(),
              Paint()
                ..color = brdColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = borderSize);
        }

        break;
      case MarkerShape.square:
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(x, y), width: radius * 2, height: radius * 2),
            Paint()..color = bgColor);
        if (borderSize > 0) {
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset(x, y), width: radius * 2, height: radius * 2),
              Paint()
                ..color = brdColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = borderSize);
        }
        break;
      case MarkerShape.diamond:
        canvas.drawPath(
            Path()
              ..moveTo(x, y - radius)
              ..lineTo(x + radius, y)
              ..lineTo(x, y + radius)
              ..lineTo(x - radius, y)
              ..close(),
            Paint()..color = bgColor);
        if (borderSize > 0) {
          canvas.drawPath(
              Path()
                ..moveTo(x, y - radius)
                ..lineTo(x + radius, y)
                ..lineTo(x, y + radius)
                ..lineTo(x - radius, y)
                ..close(),
              Paint()
                ..color = brdColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = borderSize);
        }
        break;

      case MarkerShape.barre:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
                x - radius, y - radius, barreLength + 2 * radius, 2 * radius),
            Radius.circular(radius),
          ),
          Paint()..color = bgColor,
        );
        if (borderSize > 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  x - radius, y - radius, barreLength + 2 * radius, 2 * radius),
              Radius.circular(radius),
            ),
            Paint()
              ..color = brdColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = borderSize,
          );
        }

      case MarkerShape.none:
        break;
    }
    if (marker.text != null) {
      if (marker.shape == MarkerShape.barre) {
        drawString(
            canvas,
            size,
            Offset(x + barreLength / 2, y),
            marker.text ?? "",
            marker.radius as double? ?? radius * 1.2,
            txtColor,
            marker.fontFamily ?? parent.fontFamily);
      } else {
        drawString(
            canvas,
            size,
            Offset(x, y),
            marker.text ?? "",
            marker.radius as double? ?? radius * 1.2,
            txtColor,
            marker.fontFamily ?? parent.fontFamily);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void drawString(Canvas canvas, Size size, Offset offset, String character,
    double fontSize, Color color, String fontFamily) {
  final textSpan = TextSpan(
    text: character,
    style: TextStyle(
      fontSize: fontSize,
      color: color,
      fontFamily: fontFamily,
    ),
  );

  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout(
    minWidth: 0,
    maxWidth: size.width,
  );

  textPainter.paint(
    canvas,
    Offset(
        offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2),
  );
}
