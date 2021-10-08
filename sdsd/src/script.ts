import {PaymentMethods, Configuration, Console} from '@shopify/scripts-checkout-apis';

export function paymentMethodsHandler(
  input: PaymentMethods.Input,
  configuration: Configuration, // eslint-disable-line @shopify/assemblyscript/no-unused-vars
): PaymentMethods.Result {
  // Use `Console.log` to print output from your script.
  Console.log('Hello, world');

  const sortResponse = new PaymentMethods.SortResponse(input.paymentMethods);
  const filterResponse = new PaymentMethods.FilterResponse([]);
  const renameResponse = new PaymentMethods.RenameResponse([]);

  return new PaymentMethods.Result(sortResponse, filterResponse, renameResponse);
}
