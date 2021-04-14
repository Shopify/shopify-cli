import {Product, ProductPolicyValidation} from '@shopify/extension-point-as-product-policy-validations';
import {Configuration} from '@shopify/scripts-sdk-as';
import {productPolicyValidationsHandler} from '../src/script';

describe('productPolicyValidationsHandler', () => {
  it('returns validation check', () => {
    // Fake input creation - you can use the builder classes in TestHelper
    // to create the appropriate fake input to be able to test your code!
    const input = new Product(
      1234,
      1,
      'Burton Custom Freestyle 151',
      'Burton',
      'Snowboard',
      true,
      0,
      'active',
      null
    );
    const expectedProductPolicyValidation = new ProductPolicyValidation(
      input.id,
      input.shopId,
      true,
      null,
      null
    );

    const configuration = Configuration.fromMap(new Map<string, string>());
    const actualPolicyValidation = productPolicyValidationsHandler(input, configuration);

    // Please see https://tenner-joshua.gitbook.io/as-pect/as-api
    // to learn about the as-pect API!
    expect(actualPolicyValidation).toStrictEqual(expectedProductPolicyValidation);

    // Use as-pect's `log` function to log output to your console
    log('Hello! This is a log from your test!');
  });
});
