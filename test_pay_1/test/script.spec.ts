import {
  CheckoutDomain as Domain,
  PaymentMethods,
  Currencies,
  Configuration,
  Money,
} from '@shopify/scripts-checkout-apis';
import {paymentMethodsHandler} from '../src/script';

function newPaymentMethod(name: string, cards: string[] = []): PaymentMethods.PaymentMethod {
  return new PaymentMethods.PaymentMethod(1, name, cards);
}

/**
 * This function uses builder classes from Domain.TestHelper
 * to make it easier to create fake input objects such as
 * a Checkout. Edit this function or create copies to define
 * your own custom checkout objects to test against.
 */
function createPurchaseProposal(): Domain.PurchaseProposal {
  return new Domain.TestHelper.PurchaseProposalBuilder()
    .setLines([
      Domain.TestHelper.PurchaseProposalBuilder.line(
        new Domain.TestHelper.VariantBuilder()
          .withProduct(new Domain.TestHelper.ProductBuilder().titled('Red Delicious').addTag('fruits').buildWithId(1))
          .buildWithId(1),
        1,
        Money.fromAmount(1, Currencies.CAD),
      ),
      Domain.TestHelper.PurchaseProposalBuilder.line(
        new Domain.TestHelper.VariantBuilder()
          .withProduct(new Domain.TestHelper.ProductBuilder().titled('Florida').addTag('fruits').buildWithId(2))
          .buildWithId(2),
        1,
        Money.fromAmount(1, Currencies.CAD),
      ),
    ])
    .build();
}

describe('paymentMethodsHandler', () => {
  it('does nothing', () => {
    const purchaseProposal: Domain.PurchaseProposal = createPurchaseProposal();
    const paymentMethods = [
      newPaymentMethod('2'),
      newPaymentMethod('3', ['visa', 'mc', 'amex']),
      newPaymentMethod('1'),
      newPaymentMethod('4'),
    ];

    const result: PaymentMethods.Result = paymentMethodsHandler(
      new PaymentMethods.Input(purchaseProposal, paymentMethods),
      new Configuration([]),
    );

    const sortResponse = result.sortResponse!;

    expect(sortResponse.proposedOrder[0].name).toBe('2');
    expect(sortResponse.proposedOrder[1].name).toBe('3');
    expect(sortResponse.proposedOrder[2].name).toBe('1');
    expect(sortResponse.proposedOrder[3].name).toBe('4');

    expect(sortResponse.proposedOrder.length).toBe(4);
    expect(result.renameResponse!.renameProposals.length).toBe(0);
    expect(result.filterResponse!.hiddenMethods.length).toBe(0);
  });
});
