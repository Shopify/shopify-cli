import {run} from '@shopify/scripts-sdk-as';
import {registerProductPolicyValidationsHandler} from '@shopify/extension-point-as-product-policy-validations';
import {productPolicyValidationsHandler} from './script';

// eslint-disable-next-line @shopify/assemblyscript/camelcase
export function shopify_main(): void {
  registerProductPolicyValidationsHandler(productPolicyValidationsHandler);
  run();
}
