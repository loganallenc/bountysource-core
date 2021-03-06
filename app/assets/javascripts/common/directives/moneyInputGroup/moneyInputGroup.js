angular.module('directives').directive('moneyInputGroup', function ($currency) {

  return {
    restrict: 'EAC',
    templateUrl: 'common/directives/moneyInputGroup/moneyInputGroup.html',
    transclude: true,
    scope: { currency: '=', small: '&', large: '&' },
    link: function(scope) {

      scope.$currency = $currency;
      scope.currency = scope.currency || $currency.value;

      scope.setCurrencyUSD = function () { scope.currency = 'USD'; };
      scope.setCurrencyBTC = function () { scope.currency = 'BTC'; };
      scope.setCurrencyBCH = function () { scope.currency = 'BCH'; };

      // If the currency is globally set to USD, ensure that input currency is USD
      scope.$on($currency.currencyChangedEventName, function () {
        if ($currency.isUSD()) {
          scope.currency = 'USD';
        } else if ($currency.isBTC()) {
          scope.currency = 'BTC';
        } else if ($currency.isBCH()) {
          scope.currency = 'BCH';
        }
      });

    }
  };

});
