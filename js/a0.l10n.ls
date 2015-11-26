/**
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
 */
cs.Language	= {}
new XMLHttpRequest
	..open('GET', '/manifest.webapp', true)
	..overrideMimeType('application/json')
	..onload = !->
		if @status != 200
			console.error("Can't load manifest O_o")
			return
		manifest	= JSON.parse(@response)
		for language in navigator.languages
			if language == manifest.default_locale || manifest.locales[language]
				new XMLHttpRequest
					..open('GET', "/locales/#language", true)
					..overrideMimeType('text/plain')
					..onload = !->
						if @status != 200
							console.error("Can't load locale, did you add it to manifest?")
							return
						for translation in @response.split("\n")
							if !translation
								continue
							[key, value] = translation.split('=', 2)
							cs.Language[key.trim()]	= value.trim()
						cs.Language._ready	= true
					..send()
				break
	..send()
window.__	= (key) ->
	cs.Language[key]
