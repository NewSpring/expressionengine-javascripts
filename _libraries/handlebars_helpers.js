Handlebars.getTemplate = function(name, raw) {
  sendBack = HandlebarsTemplates['handlebars/' + name]
  return sendBack
};

Handlebars.registerHelper('list', function(items, options) {
    var out = "<ul>";

    for (var i = 0, l = items.length; i < l; i++) {
        out = out + "<li>" + options.fn(items[i]) + "</li>";
    }

    return out + "</ul>";
});

// debug helper
// usage: {{debug}} or {{debug someValue}}
// from: @commondream (http://thinkvitamin.com/code/handlebars-js-part-3-tips-and-tricks/)
Handlebars.registerHelper("debug", function(optionalValue) {
  console.log("Current Context");
  console.log("====================");
  console.log(this);

  if (optionalValue) {
    console.log("Value");
    console.log("====================");
    console.log(optionalValue);
  }
});


//  return the first item of a list only
// usage: {{#first items}}{{name}}{{/first}}
Handlebars.registerHelper('first', function(context, block) {
  return block(context[0]);
});



// a limited 'each' loop.
// usage: {{#limit items offset="1" limit="5"}} : items 1 thru 6
// usage: {{#limit items limit="10"}} : items 0 thru 9
// usage: {{#limit items offset="3"}} : items 3 thru context.length
// defaults are offset=0, limit=5
Handlebars.registerHelper('limit', function(context, options) {

  var ret = "",
  offset = parseInt(options.hash.offset) || 0,
  limit = parseInt(options.hash.limit) || 5,
  i = (offset < context.length) ? offset : 0,
  j = ((limit + offset) < context.length) ? (limit + offset) : context.length;

  for(i,j; i<j; i++) {
    ret += options.fn(context[i]);
  }

  return ret;
});


// return a url without http:// or https:// or //
Handlebars.registerHelper('protocolLess', function(context) {

  // url = context.replace(/\/\//g, "");
  url = context.replace(/(.*?)\/\//, "");

  return new Handlebars.SafeString(
    url
  );
})

// return just the site from a url
Handlebars.registerHelper('justSite', function(context) {

  // siteArray = context.replace(/\/\//g, "");
  siteArray = context.replace(/(.*?)\/\//, "");
  siteArray = siteArray.split('/');
  siteArray = siteArray[0];

  return new Handlebars.SafeString(
    siteArray
  );
})

//  return a comma-serperated list from an iterable object
// usage: {{#toSentance tags}}{{name}}{{/toSentance}}
Handlebars.registerHelper('toSentance', function(context, block) {
  var ret = "";
  for(var i=0, j=context.length; i<j; i++) {
    ret = ret + block(context[i]);
    if (i<j-1) {
      ret = ret + ", ";
    };
  }
  return ret;
});
