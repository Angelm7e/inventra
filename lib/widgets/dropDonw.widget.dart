import 'package:flutter/material.dart';
import 'package:inventra/utils/colors.dart';

class InvDropDownWidget extends StatefulWidget {
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String?> onChanged;
  final double fontSize;
  final IconData icon;

  const InvDropDownWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.fontSize = 25,
    this.icon = Icons.credit_card,
  });

  @override
  _InvDropDownWidgetState createState() => _InvDropDownWidgetState();
}

class _InvDropDownWidgetState extends State<InvDropDownWidget>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool isDropDownOpen = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  _boxDecoration() {
    if (!isDropDownOpen) {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightSecondary, width: 1),
      );
    } else {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border.all(color: AppColors.lightPrimary, width: 2),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (isDropDownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    double screenHeight = MediaQuery.of(context).size.height;
    double spaceBelow = screenHeight - offset.dy - renderBox.size.height;

    double dropdownHeight = (widget.items.length * 50.0).clamp(
      50.0,
      spaceBelow,
    );

    setState(() {
      isDropDownOpen = true;
    });

    _overlayEntry = _createOverlayEntry(dropdownHeight);
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
  }

  void _removeDropdown() {
    // Quita la entrada del overlay si existe
    _overlayEntry?.remove();
    _overlayEntry = null;

    // Solo cambia el estado si el widget sigue montado
    if (mounted) {
      setState(() {
        isDropDownOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry(double dropdownHeight) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: renderBox.size.width,
            top: offset.dy + renderBox.size.height,
            left: offset.dx,
            child: Material(
              color: Colors.transparent,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, renderBox.size.height),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    // Controlling max heigth for dropdown
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.lightPrimary,
                              width: 2,
                            ),
                            left: BorderSide(
                              color: AppColors.lightPrimary,
                              width: 2,
                            ),
                            right: BorderSide(
                              color: AppColors.lightPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        child: IntrinsicHeight(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: widget.items.asMap().entries.map((
                                entry,
                              ) {
                                int index = entry.key;
                                String value = entry.value;
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {});
                                        widget.onChanged(value);
                                        _removeDropdown();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                value,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: AppColors.lightPrimary,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (index < widget.items.length - 1)
                                      const Divider(
                                        color: AppColors.lightPrimary,
                                        thickness: 1,
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size base = MediaQuery.of(context).size;
    // final serv = Provider.of<PolizaProvider>(context, listen: true);
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: AnimatedContainer(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: _boxDecoration(),
          duration: Duration(milliseconds: 500),
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: base.width * 0.67,
                  child: Text(
                    widget.selectedItem,
                    overflow: TextOverflow.ellipsis,
                    style: isDropDownOpen
                        ? const TextStyle(
                            color: AppColors.lightPrimary,
                            fontSize: 18,
                          )
                        : const TextStyle(
                            color: AppColors.lightSecondary,
                            fontSize: 18,
                          ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 1,
                      color: isDropDownOpen
                          ? AppColors.lightPrimary
                          : AppColors.lightSecondary,
                    ),
                    TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0,
                        end: isDropDownOpen ? 0.5 : 0,
                      ),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, double angle, child) {
                        return Transform.rotate(
                          angle: angle * 6.3,
                          child: isDropDownOpen
                              ? const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.lightPrimary,
                                )
                              : const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.lightSecondary,
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
