import {Product, ProductPolicyValidation} from '@shopify/extension-point-as-product-policy-validations';
import {Configuration, Console} from '@shopify/scripts-sdk-as';

export function productPolicyValidationsHandler(
  input: Product,
  configuration: Configuration, // eslint-disable-line @shopify/assemblyscript/no-unused-vars
): ProductPolicyValidation {
  const productId = input.id;
  const shopId = input.shopId;
  Console.log(`Product id ${productId}`);

  return new ProductPolicyValidation(
    productId,
    shopId,
    false,
    null,
    null
  );
}
