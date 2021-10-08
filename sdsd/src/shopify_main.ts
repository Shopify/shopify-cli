import {run, PaymentMethods} from '@shopify/scripts-checkout-apis';
import {paymentMethodsHandler} from './script';

// eslint-disable-next-line @shopify/assemblyscript/camelcase
export function shopify_main(): void {
  PaymentMethods.registerPaymentMethodsHandler(paymentMethodsHandler);
  run();
}
