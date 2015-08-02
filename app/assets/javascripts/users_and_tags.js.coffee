class window.DataAndTaggings
	constructor: ->
		@setup()

	setup: ->
		@changeDataGroupBox()
		@changeDataTaggingBox()
		@expandGroupChild()
		@changeCountryBox()
		@assignGroupData()


	changeDataGroupBox: ->
		$("#content-tabs").delegate "#data_group", "change", ->
			loadContentTab("users_and_tags/group_content?group=" + $(this).val(), "#group-detail", {})

	changeCountryBox: ->
		$("#content-tabs").delegate "#data_country", "change", ->
			if $(".icon-chevron-up").length > 0
				loadContentTab("users_and_tags/group_detail?group=" + $("#data_group").val(), "#data-detail", {})

	changeDataTaggingBox: ->
		$("#content-tabs").delegate "#data_tagging", "change", ->
			loadContentTab("users_and_tags/tagging_content?tagging=" + $(this).val(), "#data-detail", {})

	expandGroupChild: ->
		$("#content-tabs").delegate ".expand-data", "click", (e)->
			e.preventDefault()
			group_id = $("#data_group").val()
			country_id = $("#data_country").val()
			click = $(this).find("a").first()
			if click.hasClass("icon-chevron-down")
				if $(this).hasClass("tagging-data")
					loadContentTab("users_and_tags/tagging_child_data?group=" + $("#data_tagging").val() + "&group_id=" + $(this).attr("id"), "#child_" + $(this).attr("id"),{})
				else
					loadContentTab("users_and_tags/group_child_data?group=" + group_id + "&country=" + country_id + "&group_id=" + $(this).attr("id"), "#child_" + $(this).attr("id"),{})
				click.removeClass().addClass("icon-chevron-up")
			else if click.hasClass("icon-chevron-up")
				id = "#child_" + $(this).attr("id")
				$(id).html("")
				click.removeClass().addClass("icon-chevron-down")

	assignGroupData: ->
		$("#content-tabs").delegate ".assign-data", "click", (e)->
			e.preventDefault()
			group = $("#data_group").val()
			group_id = $(this).attr("data_group")
			checked_arrs = $("#child_" + group_id + " input:checked")
			unchecked_arrs = $("#child_" + group_id + " input:checkbox:not(:checked)")
			ids = []
			un_ids = []
			data_text = []
			country_id = $('#data_country').val()
			for ch in checked_arrs
				ids.push($(ch).attr("value"))
				data_text.push([$(ch).attr("value"), $(ch).parent().text().trim('')])
			for uch in unchecked_arrs
				un_ids.push($(uch).attr("value"))
			data = {group: group, group_id: group_id, ids: ids.join("__"), un_ids: un_ids.join("__"), data_text: data_text, country: country_id}
			if $("#data_tagging").length > 0
				data = {group: $("#data_tagging").val(), group_id: group_id, ids: ids.join("__"), un_ids: un_ids.join("__") }
				url = "users_and_tags/assign_tagging"
			else
				data = {group: group, group_id: group_id, ids: ids.join("__"), un_ids: un_ids.join("__"), data_text: data_text, country_id: country_id}
				url = "users_and_tags/assign_data"
			$.ajax
				url: url
				type: "PUT"
				data: data
				success: (res) ->
					if $("#data_tagging").length > 0
						loadContentTab("users_and_tags/tagging_content?tagging=" + $("#data_tagging").val(), "#data-detail", {})
					else
						loadContentTab("users_and_tags/group_detail?group=" + group, "#data-detail", {})
					return
				error: (xhr, textStatus, error) ->
					return