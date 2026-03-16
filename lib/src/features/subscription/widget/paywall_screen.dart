import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/connectivity/widget/internet_required_body.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/subscription/bloc/paywall_bloc.dart';
import 'package:pauza/src/features/subscription/widget/paywall_product_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.paywall);
  }

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late final PauzaDependencies _dependencies;
  PaywallBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _dependencies = PauzaDependencies.of(context);
    _ensureBloc();
  }

  void _ensureBloc() {
    if (_bloc != null) return;
    _bloc = PaywallBloc(
      subscriptionRepository: _dependencies.subscriptionRepository,
      currentUserBloc: RootScope.of(context).currentUserBloc,
    )..add(const PaywallStarted());
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paywallTitle), centerTitle: true),
      body: SafeArea(
        child: InternetRequiredBody(
          gate: _dependencies.internetHealthGate,
          offlineMessage: l10n.paywallOfflineMessage,
          child: Builder(
            builder: (context) {
              _ensureBloc();
              return BlocProvider.value(
                value: _bloc!,
                child: BlocConsumer<PaywallBloc, PaywallState>(
                  listener: (context, state) {
                    if (state.purchaseSuccess) {
                      Navigator.of(context).pop();
                    }
                  },
                  builder: (context, state) {
                    if (state.isLoadingOfferings) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium),
                      child: _PaywallBody(bloc: _bloc!, state: state),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaywallBody extends StatefulWidget {
  const _PaywallBody({required this.bloc, required this.state});

  final PaywallBloc bloc;
  final PaywallState state;

  @override
  State<_PaywallBody> createState() => _PaywallBodyState();
}

class _PaywallBodyState extends State<_PaywallBody> {
  Package? _selectedPackage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = widget.state;
    final selectedPackage = _selectedPackage ?? (state.packages.isNotEmpty ? state.packages.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: PauzaSpacing.extraLarge),
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
              color: context.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PauzaSpacing.medium),
              child: Icon(Icons.workspace_premium_rounded, size: 48, color: context.colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: PauzaSpacing.medium),
        Text(l10n.paywallTitle, style: context.textTheme.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: PauzaSpacing.small),
        Text(
          l10n.paywallDescription,
          style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PauzaSpacing.extraLarge),
        Expanded(
          child: ListView.separated(
            itemCount: state.packages.length,
            separatorBuilder: (_, index) => const SizedBox(height: PauzaSpacing.medium),
            itemBuilder: (context, index) {
              final package = state.packages[index];
              return PaywallProductCard(
                package: package,
                isSelected: package.identifier == selectedPackage?.identifier,
                onTap: () => setState(() => _selectedPackage = package),
              );
            },
          ),
        ),
        const SizedBox(height: PauzaSpacing.medium),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: PauzaSpacing.small),
            child: Text(
              l10n.paywallErrorGeneric,
              style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        PauzaFilledButton(
          title: Text(
            state.isPurchasing
                ? l10n.paywallPurchasing
                : l10n.paywallPurchaseButton(selectedPackage?.storeProduct.priceString ?? ''),
          ),
          disabled: state.isPurchasing || selectedPackage == null,
          onPressed: () {
            if (selectedPackage != null) {
              widget.bloc.add(PaywallPurchaseRequested(package: selectedPackage));
            }
          },
        ),
        const SizedBox(height: PauzaSpacing.small),
        PauzaTextButton(
          title: Text(l10n.paywallRestoreButton),
          disabled: state.isPurchasing,
          onPressed: () => widget.bloc.add(const PaywallRestoreRequested()),
        ),
        const SizedBox(height: PauzaSpacing.medium),
      ],
    );
  }
}
