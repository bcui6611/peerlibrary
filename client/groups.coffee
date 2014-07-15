Catalog.create 'groups', Group,
  main: Template.groups
  count: Template.groupsCount
  loading: Template.groupsLoading
,
  active: 'groupsActive'
  ready: 'currentGroupsReady'
  loading: 'currentGroupsLoading'
  count: 'currentGroupsCount'
  filter: 'currentGroupsFilter'
  limit: 'currentGroupsLimit'
  sort: 'currentGroupsSort'

Deps.autorun ->
  if Session.equals 'groupsActive', true
    Meteor.subscribe 'my-groups'

Template.groups.catalogSettings = ->
  documentClass: Group
  variables:
    filter: 'currentGroupsFilter'
    sort: 'currentGroupsSort'

Template.groups.events
  'submit .add-group': (e, template) ->
    e.preventDefault()

    name = $(template.findAll '.name').val().trim()
    return unless name

    Meteor.call 'create-group', name, (error, groupId) =>
      return Notify.meteorError error, true if error

      Notify.success "Group created."

    return # Make sure CoffeeScript does not return anything

Template.myGroups.myGroups = ->
  Group.documents.find
    _id:
      $in: _.pluck Meteor.person(inGroups: 1)?.inGroups, '_id'
  ,
    sort: [
      ['name', 'asc']
    ]

Editable.template Template.groupCatalogItemName, ->
  @data.hasMaintainerAccess Meteor.person @data.constructor.maintainerAccessPersonFields()
,
  (name) ->
    Meteor.call 'group-set-name', @data._id, name, (error, count) ->
      return Notify.meteorError error, true if error
,
  "Enter group name"
,
  true

Template.groupName[method] = Template.groupCatalogItemName[method] for method in ['created', 'rendered', 'destroyed']

Template.groupCatalogItem.countDescription = ->
  if @membersCount is 1 then "1 member" else "#{ @membersCount } members"
