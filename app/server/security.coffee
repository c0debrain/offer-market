###
# The following security definitions use the ongoworks:security package.
# Rules within a single chain stack with AND relationship. Multiple
# chains for the same collection stack with OR relationship.
# See https://github.com/ongoworks/meteor-security
#
# It's important to note that these security rules are for inserts,
# updates, and removes initiated from untrusted (client) code.
# Thus there may be other actions that certain roles are allowed to
# take, but they do not necessarily need to be listed here if the
# database operation is executed in a server method.
###

###
# Assign to some local variables to keep code
# short and sweet
###
Media = OfferMarket.Collections.Media
Products = OfferMarket.Collections.Products
Shops = OfferMarket.Collections.Shops
Tags = OfferMarket.Collections.Tags

###
# Define some additional rule chain methods
###

Security.defineMethod 'ifShopIdMatches',
	fetch: []
	deny: (type, arg, userId, doc) ->
		return doc.shopId isnt OfferMarket.getShopId()

Security.defineMethod 'ifShopIdMatchesThisId',
	fetch: []
	deny: (type, arg, userId, doc) ->
		return doc._id isnt OfferMarket.getShopId()

Security.defineMethod 'ifFileBelongsToShop',
	fetch: []
	deny: (type, arg, userId, doc) ->
		return doc.metadata.shopId isnt OfferMarket.getShopId()

# If userId prop matches userId or both are not set
Security.defineMethod 'ifUserIdMatches',
	fetch: []
	deny: (type, arg, userId, doc) ->
		return (userId and doc.userId and doc.userId isnt userId) or (doc.userId and !userId)

# Generic check for userId against any prop
# TODO might be good to have this in the
# ongoworks:security pkg as a built-in rule
Security.defineMethod 'ifUserIdMatchesProp',
	fetch: []
	deny: (type, arg, userId, doc) ->
		return doc[arg] isnt userId

###
# Define all security rules
###

###
# Permissive security for users with the 'admin' role
###
Security.permit(['insert', 'update', 'remove'])
	.collections([ Products, Tags ])
	.ifHasRole({ role: 'admin', group: OfferMarket.getShopId()} )
	.ifShopIdMatches()
	.exceptProps(['shopId'])
	.apply()

###
# Permissive security for users with the 'admin' role for FS.Collections
###
Security.permit(['insert', 'update', 'remove'])
	.collections([Media])
	.ifHasRole({ role: ['admin','owner','createProduct'], group: OfferMarket.getShopId()} )
	.ifFileBelongsToShop()
	# TODO should be a check here or elsewhere to
	# make sure we don't allow editing metadata.shopId
	.apply()


###
# Users with the 'admin' or 'owner' role may update and
# remove products, but createProduct allows just for just a product editor
###
Products.permit(['insert','update', 'remove'])
	.ifHasRole({ role: ['createProduct'], group: OfferMarket.getShopId()} )
	.ifShopIdMatchesThisId()
	.apply()


# Allow anonymous file downloads
# XXX This is probably not actually how we want to handle file download security.
_.each [ Media ], (fsCollection) ->
	fsCollection.allow
		download: -> return true
