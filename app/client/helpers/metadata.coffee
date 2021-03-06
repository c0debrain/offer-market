###
# Spiderable method to set meta tags for crawl
# accepts current iron-router route
###
OfferMarket.MetaData =
  settings: {
    title: ''
    meta: []
    ignore: ['viewport','fragment']
  }
  #render and append new metadata
  render:(route) ->
    metaContent =  Blaze.toHTMLWithData(Template.coreHead, Router.current().getName )
    $('head').append(metaContent)
    return  metaContent


  #clear all previously added metadata
  clear: ->
    $("title").remove()
    for m in $("meta")
      $m = $(m)
      property = $m.attr('name') or $m.attr('property')
      if property and property not in OfferMarket.MetaData.settings.ignore
        $m.remove()

  # update meta data
  update: (route, params, meta) ->
    return false unless Router.current()

    product = selectedProduct()
    shop = Shops.findOne(OfferMarket.getShopId())
    meta = []
    title = ""
    # set meta data
    OfferMarket.MetaData.name = shop.name if shop?.name

    # tag/category titles
    if params._id
      title = params._id.charAt(0).toUpperCase() + params._id.substring(1)
    else
      routeName = Router.current().route.getName() #route name
      title = routeName.charAt(0).toUpperCase() + routeName.substring(1) # Uppercase

    # product specific
    if product and product.handle is params._id and product.handle
      meta.push 'name': 'description', 'content': product.description if product?.description
      keywords = (key.value for key in product.metafields) if product?.metafields
      meta.push 'name': 'keywords',  'content': keywords.toString() if keywords
      title = product.title if product?.title
    else
      meta.push 'description': shop.description if shop?.description
      meta.push 'keywords': shop.keywords if shop?.keywords
    #export meta to OfferMarket.MetaData
    OfferMarket.MetaData.title = title
    OfferMarket.MetaData.meta = meta

  #wrap clear,update,render into single method
  refresh: (route, params, meta) ->
    OfferMarket.MetaData.clear(route)
    OfferMarket.MetaData.update(route, params, meta)
    OfferMarket.MetaData.render(route)
