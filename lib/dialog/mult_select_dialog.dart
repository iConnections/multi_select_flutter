import 'package:flutter/material.dart';
import '../util/multi_select_actions.dart';
import '../util/multi_select_item.dart';
import '../util/multi_select_list_type.dart';
import 'package:auto_size_text/auto_size_text.dart';


/// A dialog containing either a classic checkbox style list, or a chip style list.
class MultiSelectDialog<V> extends StatefulWidget with MultiSelectActions<V> {
  /// List of items to select from.
  final List<MultiSelectItem<V>> items;

  /// The list of selected values before interaction.
  final List<V>? initialValue;

  /// The text at the top of the dialog.
  final Widget? title;

  /// Fires when the an item is selected / unselected.
  final void Function(List<V>)? onSelectionChanged;

  /// Fires when confirm is tapped.
  final void Function(List<V>)? onConfirm;

  /// Toggles search functionality.
  final bool? searchable;

  /// Text on the confirm button.
  final Text? confirmText;

  /// Text on the cancel button.
  final Text? cancelText;
  
  final String buttonText;
  
  final bool isDark;

  /// An enum that determines which type of list to render.
  final MultiSelectListType? listType;

  /// Sets the color of the checkbox or chip when it's selected.
  final Color? selectedColor;

  /// Sets a fixed height on the dialog.
  final double? height;

  /// Set the placeholder text of the search field.
  final String? searchHint;

  /// A function that sets the color of selected items based on their value.
  /// It will either set the chip color, or the checkbox color depending on the list type.
  final Color? Function(V)? colorator;

  /// The background color of the dialog.
  final Color? backgroundColor;

  /// The color of the chip body or checkbox border while not selected.
  final Color? unselectedColor;

  /// Icon button that shows the search field.
  final Widget? searchIcon;

  /// Icon button that hides the search field
  final Widget? closeSearchIcon;

  /// Style the text on the chips or list tiles.
  final TextStyle? itemsTextStyle;

  /// Style the text on the selected chips or list tiles.
  final TextStyle? selectedItemsTextStyle;

  /// Style the search text.
  final TextStyle? searchTextStyle;

  /// Style the search hint.
  final TextStyle? searchHintStyle;

  /// Set the color of the check in the checkbox
  final Color? checkColor;
  
  final TextEditingController? controller;

  MultiSelectDialog({
    required this.items,
    required this.initialValue,
    this.title,
    this.onSelectionChanged,
    this.onConfirm,
    this.listType,
    this.searchable,
    this.confirmText,
    this.cancelText,
    this.selectedColor,
    this.searchHint,
    this.height,
    this.colorator,
    this.backgroundColor,
    this.unselectedColor,
    this.searchIcon,
    this.closeSearchIcon,
    this.itemsTextStyle,
    this.searchHintStyle,
    this.searchTextStyle,
    this.selectedItemsTextStyle,
    this.checkColor,
     this.buttonText = 'OK',
     this.isDark = false,
    this.controller,
  });

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>(items);
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  List<V> _selectedValues = [];
  bool _showSearch = false;
  List<MultiSelectItem<V>> _items;

  _MultiSelectDialogState(this._items);

  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectedValues.addAll(widget.initialValue!);
    }
  }

  /// Returns a CheckboxListTile
  Widget _buildListItem(MultiSelectItem<V> item) {
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: widget.unselectedColor ?? Colors.black54,
        accentColor: widget.selectedColor ?? Theme.of(context).primaryColor,
      ),
      child: CheckboxListTile(
        checkColor: widget.checkColor,
        value: _selectedValues.contains(item.value),
        activeColor: widget.colorator != null
            ? widget.colorator!(item.value) ?? widget.selectedColor
            : widget.selectedColor,
        title: Text(
          item.label,
          style: _selectedValues.contains(item.value)
              ? widget.selectedItemsTextStyle
              : widget.itemsTextStyle,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (checked) {
          setState(() {
            _selectedValues = widget.onItemCheckedChange(
                _selectedValues, item.value, checked!);
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged!(_selectedValues);
          }
        },
      ),
    );
  }

  /// Returns a ChoiceChip
  Widget _buildChipItem(MultiSelectItem<V> item) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        backgroundColor: widget.unselectedColor,
        selectedColor:
            widget.colorator != null && widget.colorator!(item.value) != null
                ? widget.colorator!(item.value)
                : widget.selectedColor != null
                    ? widget.selectedColor
                    : Theme.of(context).primaryColor.withOpacity(0.35),
        label: Text(
          item.label,
          style: _selectedValues.contains(item.value)
              ? TextStyle(
                  color: widget.colorator != null &&
                          widget.colorator!(item.value) != null
                      ? widget.selectedItemsTextStyle != null
                          ? widget.selectedItemsTextStyle!.color ??
                              widget.colorator!(item.value)!.withOpacity(1)
                          : widget.colorator!(item.value)!.withOpacity(1)
                      : widget.selectedItemsTextStyle != null
                          ? widget.selectedItemsTextStyle!.color ??
                              (widget.selectedColor != null
                                  ? widget.selectedColor!.withOpacity(1)
                                  : Theme.of(context).primaryColor)
                          : widget.selectedColor != null
                              ? widget.selectedColor!.withOpacity(1)
                              : null,
                  fontSize: widget.selectedItemsTextStyle != null
                      ? widget.selectedItemsTextStyle!.fontSize
                      : null,
                )
              : widget.itemsTextStyle,
        ),
        selected: _selectedValues.contains(item.value),
        onSelected: (checked) {
          setState(() {
            _selectedValues = widget.onItemCheckedChange(
                _selectedValues, item.value, checked);
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged!(_selectedValues);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      title: Column(
        children: [
          widget.title!,
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromRGBO(48, 132, 215, 0.08),
                  Color.fromRGBO(48, 132, 215, 0.4),
                  Color.fromRGBO(36, 215, 204, 0.08)
                ],
              ),
            ),
          ),
          Container(
            color: widget.isDark ? Color(0xff242A37) : Colors.white,
            margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8, left: 16),
            child: CardShadow(
              noShadow: true,
              cardHeight: 48,
              cardWidth: MediaQuery.of(context).size.width,
              radius: 8,
              isDark: widget.isDark,
              darkModeColor: Color(0xffF8F9FC),
              child: CustomPaint(
                painter: CardBorderGradientPainter(
                  strokeWidth: 1,
                  radius: 8,
                  gradient: widget.isDark
                      ? LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xff40ACD7),
    Color(0xffB770CE),
  ],
)
                      : LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xffAEF3FF),
    Color(0xff8840A0),
  ],
),
                ),
                child: Container(
                  padding: const EdgeInsets.only(left: 17, right: 17),
                  height: 48,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    minHeight: 48,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          style: TextStyle(
                            color: widget.isDark
                                ? Color(0xffF9FBFF)
                                : Color(0xff202531),
                          ),
                          cursorColor:
                              widget.isDark ? Color(0xff6C768E) : Color(0xff692B7E),
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            suffixIconConstraints: const BoxConstraints(
                                maxHeight: 22, maxWidth: 22),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                widget.controller!.text = '';

                                ///update value to ''
                              },
                              child: widget.controller!.text == ''
                                  ? widget.searchIcon
                                  : widget.closeSearchIcon,
                            ),
                            hintText: widget.searchHint,
                            hintStyle: TextStyle(
                              color: widget.isDark
                                  ? Color(0xff657393)
                                  : Color(0xff515D7A),
                              fontSize: 14,
                            ),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide.none),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _items = widget.updateSearchQuery(val, widget.items);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromRGBO(48, 132, 215, 0.08),
                  Color.fromRGBO(48, 132, 215, 0.4),
                  Color.fromRGBO(36, 215, 204, 0.08)
                ],
              ),
            ),
          ),
        ],
      ),
      contentPadding:
          widget.listType == null || widget.listType == MultiSelectListType.LIST
              ? const EdgeInsets.only(top: 12.0)
              : EdgeInsets.zero,
      insetPadding: const EdgeInsets.all(16.0),
      content: Container(
        padding: const EdgeInsets.only(left: 16, right: 16),
        height: widget.height,
        width: MediaQuery.of(context).size.width - 32,
        child: widget.listType == null ||
                widget.listType == MultiSelectListType.LIST
            ? ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildListItem(_items[index]);
                },
              )
            : SingleChildScrollView(
                child: Wrap(
                  children: _items.map(_buildChipItem).toList(),
                ),
              ),
      ),
      actions: <Widget>[
        Column(
          children: [
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromRGBO(48, 132, 215, 0.08),
                    Color.fromRGBO(48, 132, 215, 0.4),
                    Color.fromRGBO(36, 215, 204, 0.08)
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 16, bottom: 16),
                child: DefaultButton(
                  isDark: widget.isDark,
                  title: widget.buttonText,
                  width: MediaQuery.of(context).size.width / 1.5,
                  onPressed: () {
                    widget.onConfirmTap(
                        context, _selectedValues, widget.onConfirm);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DefaultButton extends StatelessWidget {
  final bool isDark;
  final String title;
  final VoidCallback onPressed;
  final bool disabled;
  final LinearGradient colorGradient;
  final Color pressedColor;
  final double height;
  final double? width;
  final bool customContent;
  final Widget? customContentWidget;
  final double borderRadius;
  final bool shrinkText;
  final Color? changeColor;
  final double? padding;
  final bool noShadow;

  const DefaultButton({
    Key? key,
    Color pressedColor = const Color(0xff692B7E),
    required this.isDark,
    required this.title,
    required this.onPressed,
    this.customContentWidget,
    this.changeColor,
    this.padding,
    this.disabled = false,
    LinearGradient? colorGradient,
    this.height = 48,
    this.width,
    this.customContent = false,
    this.borderRadius = 10,
    this.shrinkText = false,
    this.noShadow = false,
  })  : colorGradient = const LinearGradient(
  begin: Alignment(0, -2),
  end: Alignment(-1, 2),
  colors: [Color(0xff692B7E), Color(0xff16061E)],
),
        pressedColor = isDark ? const Color(0xff9E41BD) : const Color(0xff692B7E),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: disabled
          ? const BoxDecoration(color: Colors.transparent)
          : BoxDecoration(
              gradient: changeColor != null
                  ? LinearGradient(colors: [changeColor!, changeColor!])
                  : isDark
                      ? LinearGradient(
  begin: Alignment(-2, -1),
  end: Alignment(1, 1),
  colors: [Color(0xff7D4092), Color(0xffE288FF)],
)
                      : colorGradient,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return disabled ? Color(0xff6C768E) : pressedColor;
              }
              return disabled ? Color(0xff6C768E) : Colors.transparent;
            },
          ),
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return 0.0;
              return 8.0;
            },
          ),
          shadowColor: MaterialStateProperty.all(
            disabled || noShadow
                ? Colors.transparent
                : isDark
                    ? const Color.fromRGBO(197, 103, 229, 0.18)
                    : const Color.fromRGBO(83, 32, 100, 0.3),
          ),
          splashFactory: NoSplash.splashFactory,
          padding: MaterialStateProperty.all(
              padding != null ? EdgeInsets.all(padding!) : null),
        ),
        child: customContent
            ? customContentWidget
            : AutoSizeText(
                title,
                style: TextStyle(
                  fontFamily: 'Mont',
                  fontWeight: FontWeight.w700,
                  color: isDark && disabled
                      ? Color(0xffF9FBFF)
                      : isDark
                          ? Color(0xff202531)
                          : Colors.white,
                  fontSize: shrinkText ? 11.4 : 14,
                ),
              ),
      ),
    );
  }
}

class CardShadow extends StatelessWidget {
  final double? cardHeight;
  final double? cardWidth;
  final double radius;
  final bool isDark;
  final Widget child;
  final bool noShadow;
  final Color darkModeColor;

  const CardShadow({
    Key? key,
    required this.isDark,
    this.cardHeight,
    this.cardWidth,
    required this.radius,
    required this.child,
    this.noShadow = false,
    this.darkModeColor = const Color(0xff1C212B),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: cardHeight,
          width: cardWidth,
          decoration: BoxDecoration(
            color: isDark ? darkModeColor : Colors.white,
            boxShadow: noShadow
                ? []
                : [isDark ? BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.13),
  offset: Offset(4, 4),
  blurRadius: 12,
) : BoxShadow(
  color: Color.fromRGBO(121, 98, 249, 0.13),
  offset: Offset(2, 4),
  blurRadius: 12,
)],
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Container(),
        ),
        child,
      ],
    );
  }
}

class CardBorderGradientPainter extends CustomPainter {
  final Paint _paint = Paint()..color = Colors.white;
  final double radius;
  final double strokeWidth;
  final Gradient gradient;
  final bool bold;
  final bool disabled;

  CardBorderGradientPainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradient,
    this.bold = false,
    this.disabled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    Rect outerRect = Offset.zero & size;
    var outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    Rect innerRect = Rect.fromLTWH(strokeWidth, strokeWidth,
        size.width - strokeWidth * 2, size.height - strokeWidth * 2);
    var innerRRect = RRect.fromRectAndRadius(
        innerRect, Radius.circular(radius - strokeWidth));

    // apply gradient shader
    if (!bold || disabled) {
      _paint.shader = gradient.createShader(outerRect);
    }

    // create difference between outer and inner paths and draw it
    Path path1 = Path()..addRRect(outerRRect);
    Path path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);
    // canvas.rotate(math.pi / 2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}


