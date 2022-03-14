import 'package:flutter/material.dart';
import '../util/multi_select_actions.dart';
import '../util/multi_select_item.dart';
import '../util/multi_select_list_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// A dialog containing either a classic checkbox style list, or a chip style list.
class MultiSelectDialog<V> extends StatefulWidget with MultiSelectActions<V> {
  /// List of items to select from.
  final List<MultiSelectItem<V>> items;

  /// The list of selected values before interaction.
  final List<V>? initialValue;

  /// The text at the top of the dialog.
  final Widget? title;
  
  final int maxItems;
  
  final String tooManyText;
  
  final dynamic searchState;

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
    this.maxItems = 1000,
    this.selectedItemsTextStyle,
    this.checkColor,
     this.buttonText = 'OK',
    this.tooManyText = 'Too many',
     this.isDark = false,
    this.controller,
    this.searchState,
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
      print(_selectedValues);
    }
  }

  /// Returns a CheckboxListTile
  Widget _buildListItem(MultiSelectItem<V> item) {
        String getCompanyJobTitleText(String company, String jobTitle) {
      if (company == '' && jobTitle == '') {
        return '';
      } else if (company == '') {
        return jobTitle;
      } else if (jobTitle == '') {
        return company;
      } else {
        return '$company, $jobTitle';
      }
    }
    return Container(
        color: widget.isDark ? Color(0xff242A37) : Color(0xffF8F9FC),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    right: 16,
                    top: 16,
                    bottom: 16,
                  ),
                  child: CustomAvatar(
                    ///customAvatarWidget
                    imageUrl: item.imageUrl,
                    initials: item.initials,
                    isDark: widget.isDark,
                    size: 40,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            color: widget.isDark ? Color(0xffF9FBFF) : Color(0xff202531),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          getCompanyJobTitleText(
                              item.companyName,
                              item.jobTitle),
                          style: TextStyle(
                            color:
                                widget.isDark ? Color(0xffE0E9FF) : Color(0xff394155),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                CustomCheckbox(
                  isDark: widget.isDark,
                  isChecked: _selectedValues.contains(item.value),
                  onTap: () {
                    setState(() {
                      _selectedValues = widget.onItemCheckedChange(
                          _selectedValues, item.value, !_selectedValues.contains(item.value));
                    });
                    if (widget.onSelectionChanged != null) {
                      widget.onSelectionChanged!(_selectedValues);
                    }
                  },
                ),
              ],
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
      );
  }

  /// Returns a ChoiceChip
  Widget _buildChipItem(MultiSelectItem<V> item) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        height: 35,
        padding: EdgeInsets.only(left:1.5, right: 1.5, top: 0, bottom: 0),
              decoration: BoxDecoration(
                boxShadow: _selectedValues.contains(item.value) ? [BoxShadow(
  color: Color.fromRGBO(58, 64, 207, 0.26),
  offset: Offset(4, 4),
  blurRadius: 25,
)] : [],
                borderRadius: BorderRadius.circular(6),
        gradient: _selectedValues.contains(item.value) ? LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [
    Color(0xffAEF3FF),
    Color(0xff8840A0),
  ],
) : null, ),
        child: ChoiceChip(
        backgroundColor: widget.unselectedColor,
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
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
                fontWeight: widget.selectedItemsTextStyle != null
                      ? widget.selectedItemsTextStyle!.fontWeight
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
       ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.backgroundColor,
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
              darkModeColor: Color(0xff1C212B),
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

                                 setState(() {
                              _items = widget.updateSearchQuery('', widget.items);
                            });
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
                            if(widget.searchState != null){
                              context.read(widget.searchState).updateSearch(val);
                            } else {
                            setState(() {
                              _items = widget.updateSearchQuery(val, widget.items);
                            });
                            }
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
                  disabled: _selectedValues.length > widget.maxItems,
                  isDark: widget.isDark,
                  title: _selectedValues.length <= widget.maxItems ? widget.buttonText : widget.tooManyText,
                  width: MediaQuery.of(context).size.width / 1.5,
                  onPressed: () {
                  if(_selectedValues.length <= widget.maxItems){
                    widget.onConfirmTap(
                        context, _selectedValues, widget.onConfirm);
                  }
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

class CustomAvatar extends StatelessWidget {
  final String imageUrl;
  final String initials;
  final bool isDark;
  final double size;
  final EdgeInsetsGeometry margin;
  final bool isSmall;

  const CustomAvatar({
    Key? key,
    this.imageUrl = '',
    this.initials = 'X',
    required this.isDark,
    required this.size,
    this.margin = EdgeInsets.zero,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [isDark ? BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.13),
  offset: Offset(4, 4),
  blurRadius: 12,
) : BoxShadow(
  color: Color.fromRGBO(121, 98, 249, 0.13),
  offset: Offset(2, 4),
  blurRadius: 12,
)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(360),
        child: initials == '' && (imageUrl == '')
            ? Container(
                color: isDark ? Color(0xff6C768E) : Color(0xffA1A7B5),
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset(
                  'assets/faceLift/User.svg',
                  height: size,
                ),
              )
            : (imageUrl == '')
                ? Container(
                    padding: EdgeInsets.all(isSmall ? 2 : 5),
                    color: isDark ? Color(0xff6C768E) : Color(0xffA1A7B5),
                    child: Center(
                      child: AutoSizeText(
                        initials,
                        maxLines: 1,
                        maxFontSize: 21,
                        minFontSize: 8,
                        // minFontSize: 8,
                        style: TextStyle(
                          fontSize: 21,
                          color: isDark ? Color(0xffE0E9FF) : Colors.white,
                        ),
                      ),
                    ),
                  )
                : CustomCachedImage(
                    url: imageUrl,
                    initials: initials,
                    isDark: isDark,
                    isSmall: isSmall,
                    size: size,
                  ),
      ),
    );
  }
}

class CustomCachedImage extends StatelessWidget {
  final String url;
  final bool isSmall;
  final bool isDark;
  final String initials;
  final double? size;

  const CustomCachedImage({
    Key? key,
    required this.url,
    this.isSmall = false,
    required this.isDark,
    this.initials = 'X',
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return url == ''
        ? ClipRRect(
            borderRadius: BorderRadius.circular(360),
            child: Container(
              padding: EdgeInsets.all(isSmall ? 2 : 5),
              color: isDark ? Color(0xff6C768E) : Color(0xffA1A7B5),
              child: Center(
                child: AutoSizeText(
                  initials,
                  maxLines: 1,
                  maxFontSize: 28,
                  minFontSize: 8,
                  style: TextStyle(
                    fontSize: 28,
                    color: isDark ? Color(0xffE0E9FF) : Colors.white,
                  ),
                ),
              ),
            ),
          )
        : CachedNetworkImage(
            memCacheHeight: isSmall ? 200 : null,
            fit: BoxFit.fitWidth,
            imageUrl: url,
            placeholder: (context, url) {
              return Container();
            },
            height: size,
            width: size,
            errorWidget: (context, url, error) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(360),
                child: Container(
                  padding: EdgeInsets.all(isSmall ? 2 : 5),
                  color: isDark ? Color(0xff6C768E) : Color(0xffA1A7B5),
                  child: Center(
                    child: AutoSizeText(
                      initials,
                      maxLines: 1,
                      maxFontSize: 28,
                      minFontSize: 8,
                      style: TextStyle(
                        fontSize: 28,
                        color: isDark ? Color(0xffE0E9FF) : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            });
  }
}

class CustomCheckbox extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  final bool isChecked;
  final bool disabled;

  const CustomCheckbox({
    Key? key,
    required this.isDark,
    required this.onTap,
    this.isChecked = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: isChecked && isDark
                  ? const LinearGradient(
                      colors: [Color(0xff73E1FF), Color(0xff1F72A4)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    )
                  : isChecked
                      ? LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [Color(0xff2F8DBA), Color(0xff03456C)],
)
                      : null,
              // color: Colors.white,
              boxShadow: disabled
                  ? []
                  : [
                      isChecked && isDark
                          ? BoxShadow(
  color: Color.fromRGBO(58, 64, 207, 0.26),
  offset: Offset(4, 4),
  blurRadius: 25,
)
                          : isChecked
                              ? BoxShadow(
  color: Color.fromRGBO(121, 98, 249, 0.13),
  offset: Offset(2, 4),
  blurRadius: 12,
)
                              : isDark
                                  ? const BoxShadow(
                                      color: Color.fromRGBO(27, 27, 27, 0.28),
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    )
                                  : const BoxShadow(
                                      color:
                                          Color.fromRGBO(196, 180, 155, 0.28),
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                    ],
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          CustomPaint(
            painter: isChecked
                ? null
                : CardBorderGradientPainter(
                    strokeWidth: 1,
                    radius: 5,
                    gradient: disabled
                        ? const LinearGradient(
                            colors: [Color(0xffA1A7B5), Color(0xffA1A7B5)])
                        : isDark
                            ? LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [
    Color(0xff40ACD7),
    Color(0xffB770CE),
  ],
)
                            : LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [
    Color(0xffAEF3FF),
    Color(0xff8840A0),
  ],
),
                  ),
            child: Container(
              padding: isChecked
                  ? const EdgeInsets.only(
                      left: 5, right: 5, top: 5.5, bottom: 5.5)
                  : EdgeInsets.zero,
              margin: isChecked ? EdgeInsets.zero : const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: isDark ? Color(0xff1C212B) : Colors.white,
                gradient: isChecked && isDark
                    ? const LinearGradient(
                        colors: [Color(0xff73E1FF), Color(0xff1F72A4)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : isChecked
                        ? LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [Color(0xff2F8DBA), Color(0xff03456C)],
)
                        : null,
                boxShadow: disabled
                    ? []
                    : [
                        isChecked && isDark
                            ? BoxShadow(
  color: Color.fromRGBO(58, 64, 207, 0.26),
  offset: Offset(4, 4),
  blurRadius: 25,
)
                            : isChecked
                                ? BoxShadow(
  color: Color.fromRGBO(121, 98, 249, 0.13),
  offset: Offset(2, 4),
  blurRadius: 12,
)
                                : isDark
                                    ? const BoxShadow(
                                        color: Color.fromRGBO(27, 27, 27, 0.28),
                                        offset: Offset(2, 2),
                                        blurRadius: 4,
                                      )
                                    : const BoxShadow(
                                        color:
                                            Color.fromRGBO(196, 180, 155, 0.28),
                                        offset: Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                      ],
                borderRadius: BorderRadius.circular(5),
              ),
              child: isChecked
                  ? Icon(
                    Icons.check_rounded,
                      size: 11,
                      color: isDark ? Color(0xff202531) : Colors.white,
                    )
                  : const SizedBox(
                      height: 19,
                      width: 19,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

