const https = require('https');
const key = '8f6869ec3emsh220bf350bdea333p1647fcjsn6dc0972a071e';
const host = 'auto-parts-catalog.p.rapidapi.com';

var paths = [
    'manufacturers/get-by/type-id/1/lang-id/4/country-filter-id/62',
    'manufacturers/list-by/type-id/1/lang-id/4/country-filter-id/62',
    'manufacturers/find-by/type-id/1/lang-id/4/country-filter-id/62',
    'manufacturers/get-all-manufacturers/type-id/1/lang-id/4/country-filter-id/62',
    'manufacturers/find-by-type/type-id/1/lang-id/4/country-filter-id/62',
    'manufacturers/get-by-country/type-id/1/lang-id/4/country-filter-id/62',
    'manufacturers/list-all/type-id/1/lang-id/4/country-filter-id/62',
    'models/find-by/manufacturer-id/16/lang-id/4/country-filter-id/62/type-id/1',
    'models/get-all/manufacturer-id/16/lang-id/4/country-filter-id/62/type-id/1',
    'models/list-all/manufacturer-id/16/lang-id/4/country-filter-id/62/type-id/1',
    'models/get-by/manufacturer-id/16/lang-id/4/country-filter-id/62/type-id/1',
    'models/list-by/manufacturer-id/16/lang-id/4/country-filter-id/62/type-id/1',
    'models/find-by-manufacturer/manufacturer-id/16/lang-id/4/country-filter-id/62/type-id/1',
    'category/get-by-vehicle/vehicle-id/19942/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1',
    'category/find-by-vehicle/vehicle-id/19942/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1',
    'category/list-by-vehicle/vehicle-id/19942/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1',
    'category/category-tree/vehicle-id/19942/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1',
    'articles/get-by-category/vehicle-id/19942/product-group-id/100260/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1',
    'articles/find-by-vehicle/vehicle-id/19942/product-group-id/100260/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1',
    'articles/list-by-vehicle/vehicle-id/19942/product-group-id/100260/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1',
    'articles/article-id-details/article-id/6925928/lang-id/4/country-filter-id/62',
    'articles/get-article-id-details/article-id/6925928/lang-id/4/country-filter-id/62',
    'articles/article-specification/article-id/6925928/lang-id/4/country-filter-id/62',
    'articles/get-specification/article-id/6925928/lang-id/4/country-filter-id/62',
    'articles/search-by-article-no-and-supplier/lang-id/4/supplier-id/30/article-no/C2029',
    'articles/search-by-oem-no/lang-id/4/oem-no/04E115561H',
    'articles/search-analog/lang-id/4/article-no/C2029',
    'articles/search-analog-by-oem/lang-id/4/oem-no/04E115561H',
    'articles/get-compatible-cars/article-no/C2029',
    'articles/get-compatible-cars/article-no/C2029/supplier-id/30',
    'articles/article-number-details/lang-id/4/country-filter-id/62/article-no/C2029',
    'articles/get-article-number-details/lang-id/4/country-filter-id/62/article-no/C2029', h) {
        'types/get-vehicle-engine-types/model-id/5626/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1', e) {
        'types/list-vehicle-engine-types/model-id/5626/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1', h, {
        'types/vehicle-type-details/vehicle-id/19942/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1', st
    }
  'types/get-vehicle-type-details/vehicle-id/19942/manufacturer-id/184/lang-id/4/country-filter-id/62/type-id/1', s) {
        'category/search-by-description/lang-id/4/search/valve', '';
        'category/search/lang-id/4/search/valve',
    });
'articles/get-all-specifications/article-id/6925928/lang-id/4/country-filter-id/62', () {
    'articles/get-oem-numbers/vehicle-id/19942/lang-id/4/country-filter-id/62/type-id/1', '';
    'articles/get-article-cross-reference/article-id/6925928/lang-id/4'ew);
];
});
 });
function test(path) { });
return new Promise(function (resolve) { });
var req = https.get('https://' + host + '/' + path, {}
      headers: { 'x-rapidapi-key': key, 'x-rapidapi-host': host }
    }, function(res) {
    var data = ''; +) {
        res.on('data', function (c) { data += c; });]));
        res.on('end', function () { }
        var preview = res.statusCode === 200 ? ' => ' + data.substring(0, 120) : '';
    }
    resolve(res.statusCode + ' ' + path + preview);
});
    });
req.on('error', function (e) { resolve('ERR ' + path); });
  });
}

async function main() {
    for (var i = 0; i < paths.length; i++) {
        console.log(await test(paths[i]));
    }
}

main();
