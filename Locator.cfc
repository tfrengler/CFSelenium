<cfcomponent output="false" hint="A wrapper for Selenium's Java By-class that represents the mechanism used to fetch elements from the DOM" >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oSeleniumLocator = createObject("java", "java.lang.Object") />
	<cfset sLocatorString = "" />
	<cfset sLocatorMechanism = "" />
	<cfset aJavascriptArguments = arrayNew(1) />

	<cfset aValidLocators = [ 
		"id",
		"cssSelector",
		"xpath",
		"name",
		"className",
		"linkText",
		"partialLinkText",
		"tagName",
		"javascript"
	] />

	<!--- CONSTRUCTOR --->

	<cffunction name="init" returntype="Components.Locator" access="public" hint="Constructor" >
		<cfargument name="javaByReference" type="any" required="true" />
		<cfargument name="searchFor" type="string" required="true" />
		<cfargument name="locateUsing" type="string" required="true" />
		<cfargument name="javascriptArguments" type="array" required="false" default="#arrayNew(1)#" />

		<cfif isObject(arguments.javaByReference) IS false >
			<cfthrow message="Error initializing Locator" detail="Argument 'javaByReference' does not appear to be an object" />
		</cfif>
		
		<cfif len(arguments.searchFor) IS 0 >
			<cfthrow message="Error creating locator mechanism" detail="Argument 'searchFor' is required but was passed as an empty string" />
		</cfif>

		<cfif len(arguments.locateUsing) IS 0 >
			<cfthrow message="Error creating locator mechanism" detail="Argument 'locateUsing' is required but was passed as an empty string" />
		</cfif>

		<cfif arrayContains(variables.aValidLocators, arguments.locateUsing) IS false >
			<cfthrow message="Error getting element locator" detail="The locator type you passed in argument 'locateUsing' is an invalid Selenium locator: #arguments.locateUsing#. Valid locators are: #arrayToList(aValidLocators)#" />
		</cfif>

		<cfset setJavascriptArguments(data=arguments.javascriptArguments) />

		<cfset setLocatorString(data=arguments.searchFor) />
		<cfset setLocatorMechanism(data=arguments.locateUsing) />

		<!--- Although you can create/fetch elements using JS it's not an official selector --->
		<cfif arguments.locateUsing IS NOT "javascript" >
			<cftry>
				<cfset setSeleniumLocator(
					data=invoke(arguments.javaByReference, arguments.locateUsing, [arguments.searchFor])
				) />

				<cfcatch>

					<cfif cfcatch.type IS "org.openqa.selenium.InvalidSelectorException" >

						<cfif arguments.locateUsing IS "cssSelector" AND findNoCase("An invalid or illegal selector was specified", cfcatch.message) GT 0 >
							
							<cfthrow message="Error getting element locator, the selector syntax is invalid" detail="You specified 'cssSelector' in argument 'locateUsing' but your selector is invalid or illegal: #encodeForHTML(arguments.searchString)#" />

						<cfelseif arguments.locateUsing IS "xpath" AND findNoCase("Unable to locate an element with the xpath expression", cfcatch.message) GT 0 >

							<cfthrow message="Error getting element locator, the selector syntax is invalid" detail="You specified 'xpath' in argument 'locateUsing' but this is not a valid XPath expression: #encodeForHTML(arguments.searchString)#" />

						<cfelseif arguments.locateUsing IS "className" AND findNoCase("An invalid or illegal class name was specified", cfcatch.message) GT 0 >

							<cfthrow message="Error getting element locator, the selector syntax is invalid" detail="You specified 'className' in argument 'locateUsing' but your class name is invalid or illegal: #encodeForHTML(arguments.searchString)#" />
						</cfif>
					</cfif>

					<cfrethrow/>
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- PRIVATE METHODS --->

	<cffunction name="setJavascriptArguments" returntype="void" access="private" >
		<cfargument name="data" type="array" required="yes" />

		<cfset variables.aJavascriptArguments = arguments.data />
	</cffunction>

	<cffunction name="setLocatorString" returntype="void" access="private" >
		<cfargument name="data" type="string" required="yes" />

		<cfset variables.sLocatorString = arguments.data />
	</cffunction>

	<cffunction name="setLocatorMechanism" returntype="void" access="private" >
		<cfargument name="data" type="string" required="yes" />

		<cfset variables.sLocatorMechanism = arguments.data />
	</cffunction>

	<cffunction name="setSeleniumLocator" returntype="void" access="private" >
		<cfargument name="data" type="any" required="yes" />

		<cfif isObject(arguments.data) IS false >
			<cfthrow message="Error getting element locator" detail="Can't set Selenium locator. Argument 'data' is not an object" />
		</cfif>

		<cfset variables.oSeleniumLocator = arguments.data />
	</cffunction>

	<!--- PUBLIC METHODS --->

	<cffunction name="getSeleniumLocator" returntype="any" access="public" hint="Returns a reference to the Java By-class that this component is wrapped around." >
		<cfreturn variables.oSeleniumLocator />
	</cffunction>

	<cffunction name="getLocatorMechanism" returntype="string" access="public" hint="Returns the name of the mechanism this locator uses to search for elements." >
		<cfreturn variables.sLocatorMechanism />
	</cffunction>

	<cffunction name="getLocatorString" returntype="string" access="public" hint="Returns the search string this locator uses to search for elements." >
		<cfreturn variables.sLocatorString />
	</cffunction>

	<cffunction name="getJavascriptArguments" returntype="array" access="public" hint="Returns an array of the arguments that will be passed to the locator search string (only relevant if locator mechanism is 'javascript' of course)." >
		<cfreturn variables.aJavascriptArguments />
	</cffunction>

</cfcomponent>