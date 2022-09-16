import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/receive.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/chill_info_card.dart';
import 'package:fluttermint/widgets/small_balance_display.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

import 'package:qr_flutter/qr_flutter.dart';

import 'package:fluttermint/widgets/ellipsable_text.dart';

import 'package:share_plus/share_plus.dart';

final paymentStatusStreamProvider = StreamProvider.autoDispose<String?>((ref) {
  Stream<String?> getStatus() async* {
    var shouldPoll = true;
    while (shouldPoll) {
      await Future.delayed(const Duration(seconds: 1));
      await ref.read(receiveProvider.notifier).checkPaymentStatus();
      yield "pending";
    }
  }

  return getStatus();
});

class ReceiveConfirm extends ConsumerWidget {
  const ReceiveConfirm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receive = ref.read(receiveProvider);
    final receiveNotifier = ref.read(receiveProvider.notifier);

    final statusProvider = ref.watch(paymentStatusStreamProvider);

    // Don't context.go across async boundary
    ref.listen<Receive?>(receiveProvider, (_, receive) {
      if (receive?.receiveStatus == "paid") {
        context.go("/");
      }
    });

    final invoice = receive?.invoice;
    final lightningUri = "lightning:$invoice";
    final desc = receive?.description;
    final amount = receive?.amountSats;

    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Receive bitcoin",
            backAction: () {
              context.go("/receive");
            },
            closeAction: () {
              receiveNotifier.clear();
              context.go("/");
            },
          ),
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChillInfoCard(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const SizedBox(
                    //     width: 32,
                    //     height: 32,
                    //     child:
                    //         Image(image: AssetImage("assets/app/bolt-circle.png"))),
                    // const SizedBox(height: 8),
                    Text("RECEIVE",
                        style: Theme.of(context).textTheme.headline4),
                    const SizedBox(height: 16),
                    SmallBalanceDisplay(amountSats: amount ?? 0),
                    const SizedBox(height: 8),
                    Text(desc ?? "",
                        style: Theme.of(context).textTheme.bodyText2),
                    statusProvider.when(
                        data: (data) =>
                            Text(data ?? "no status something went wrong?"),
                        loading: () => const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text("loading"),
                            ),
                        error: (err, _) => Text(err.toString())),
                  ],
                )),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        QrImage(
                            data: lightningUri,
                            version: QrVersions.auto,
                            // Screen width minus 40.0 for container and 48.0 for app padding
                            // limit to 300 px
                            size: (MediaQuery.of(context).size.width - 88.0)
                                .clamp(0, 300.0)),
                        const SizedBox(height: 16),
                        EllipsableText(
                            text: invoice ?? "",
                            style: Theme.of(context).textTheme.caption),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlineGradientButton(
                        text: "Share",
                        onTap: () => Share.share(lightningUri),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                        child: OutlineGradientButton(
                      text: "Copy",
                      onTap: () =>
                          Clipboard.setData(ClipboardData(text: invoice)),
                    )),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
