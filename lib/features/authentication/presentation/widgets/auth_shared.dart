import 'package:flutter/material.dart';

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.helperText,
    this.helperActionLabel,
    this.helperActionKey,
    this.onHelperActionTap,
    this.onTapOutside,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final String? helperText;
  final String? helperActionLabel;
  final Key? helperActionKey;
  final VoidCallback? onHelperActionTap;
  final VoidCallback? onTapOutside;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: GestureDetector(
        onTap: onTapOutside,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            const _BackgroundDecoration(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AuthHeader(title: title, subtitle: subtitle),
                        const SizedBox(height: 20),
                        Material(
                          color: Colors.white,
                          elevation: 10,
                          shadowColor: const Color(0x0D000000),
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                            child: Column(
                              children: _withSpacing(children, 16),
                            ),
                          ),
                        ),
                        if (helperText != null && helperActionLabel != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                helperText!,
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
                              ),
                              TextButton(
                                key: helperActionKey,
                                onPressed: onHelperActionTap,
                                child: Text(
                                  helperActionLabel!,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> list, double spacing) {
    final items = <Widget>[];
    for (var i = 0; i < list.length; i++) {
      items.add(list[i]);
      if (i != list.length - 1) {
        items.add(SizedBox(height: spacing));
      }
    }
    return items;
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0x1F0EA5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.auto_awesome, color: Color(0xFF0284C7)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F2FF), Color(0xFFF8FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: _AccentBlob(
              size: 200,
              color: const Color(0x240EA5E9),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -20,
            child: _AccentBlob(
              size: 180,
              color: const Color(0x1F38BDF8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentBlob extends StatelessWidget {
  const _AccentBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class AuthInputField extends StatefulWidget {
  const AuthInputField({
    super.key,
    this.fieldKey,
    required this.label,
    required this.hint,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.enableToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.icon,
  });

  final Key? fieldKey;
  final String label;
  final String hint;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final bool enableToggle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final IconData? icon;

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AuthInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.fieldKey,
      onChanged: widget.onChanged,
      autocorrect: false,
      enabled: widget.enabled,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        prefixIcon: widget.icon != null ? Icon(widget.icon, color: const Color(0xFF0284C7)) : null,
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        filled: true,
        fillColor: widget.enabled ? const Color(0xFFF7FBFF) : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x0F000000)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x0F000000)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.4),
        ),
        suffixIcon: widget.enableToggle
            ? IconButton(
                onPressed: widget.enabled ? () => setState(() => _obscured = !_obscured) : null,
                icon: Icon(_obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              )
            : null,
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = enabled && !loading;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: active ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5E9),
          disabledBackgroundColor: const Color(0xFF94D3EB),
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
      ),
    );
  }
}
