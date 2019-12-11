<cfcomponent output="false" modifier="final" hint="An interface/facade that is injected into Browser.cfc (composition). It contains handy methods designed to easily grab elements with a minimum of fuss using specific, commonly used attributes such as id, class, title, name etc. All the methods (with a few exceptions) operate using cssSelectors." >

	<cfset variables.oWrappedBrowser = "" />

	<!--- CONSTRUCTOR --->

	<cffunction name="init" returntype="ElementLocator" access="public" hint="Constructor" >
		<cfargument name="browserReference" type="Browser" required="true" />

		<cfset variables.oWrappedBrowser = arguments.browserReference />
		<cfreturn this />
	</cffunction>

	<!--- PRIVATE METHODS --->

	<cffunction name="getByAttributeAndOperator" returntype="any" access="private" hint="The primary method for getting elements by their attributes depending on operator. The other public attribute-methods act as facades for this one." >
		<cfargument name="attribute" type="string" required="yes" hint="" />
		<cfargument name="value" type="string" required="yes" hint="" />
		<cfargument name="operator" type="string" required="yes" hint="" />
		<cfargument name="onlyElementsOfTag" type="string" required="yes" hint="" />
		<cfargument name="multiple" type="boolean" required="yes" hint="" />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="" />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "" />
		<cfset var oLocator = "" />

		<cfif len(arguments.value) IS 0 OR arguments.value IS " " >
			<cfthrow message="Error fetching element by attribute" detail="Argument 'value' is empty" />
		</cfif>

		<cfif len(arguments.attribute) IS 0 OR arguments.attribute IS " " >
			<cfthrow message="Error fetching element by attribute" detail="Argument 'attribute' is empty" />
		</cfif>

		<cfset sSearchString = "#trim(arguments.onlyElementsOfTag)#[#trim(arguments.attribute)##arguments.operator#='#arguments.value#']" />

		<cfset oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = sSearchString,
			locateUsing = "cssSelector"
		) />

		<cfif arguments.getLocator >
			<cfreturn oLocator />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator, multiple=true) />
		<cfelse>
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<!--- PUBLIC METHODS --->

	<cffunction name="title" returntype="any" access="public" hint="Search for and retrieve elements based on the title-attribute." >
		<cfargument name="title" type="string" required="yes" hint="The title of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain title, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "[title='#arguments.title#']" />
		<cfset var oLocator = "" />

		<cfif len(arguments.onlyElementsOfTag) GT 0 >
			<cfset sSearchString = "#arguments.onlyElementsOfTag#[title='#arguments.title#']" />
		</cfif>

		<cfset oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = sSearchString,
			locateUsing = "cssSelector"
		) />

		<cfif arguments.getLocator >
			<cfreturn oLocator />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator, multiple=true) />
		<cfelse>
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="id" returntype="any" access="public" hint="Search for and retrieve elements based on the id-attribute." >
		<cfargument name="id" type="string" required="yes" hint="The id of the elements you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain id, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found. Note that ID's are supposed to be unique and that only 1 element will be fetched, even if multiple exist with the same ID. But this parameter is still useful for checking the presence of the element." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "###arguments.id#" />
		<cfset var oLocator = "" />

		<cfif len(arguments.onlyElementsOfTag) GT 0 >
			<cfset sSearchString = "#arguments.onlyElementsOfTag##sSearchString#" />
		</cfif>

		<cfset oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = sSearchString,
			locateUsing = "cssSelector"
		) />

		<cfif arguments.getLocator >
			<cfreturn oLocator />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator, multiple=true) />
		<cfelse>
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="class" returntype="any" access="public" hint="Search for and retrieve elements based on the className-attribute." >
		<cfargument name="className" type="string" required="yes" hint="The class name or names you want to search for. You can search for both single and multiple classes, separated by spaces." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain class name (or names), rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "#arguments.onlyElementsOfTag#.#arguments.className#" />
		<cfset var oLocator = "" />

		<!--- With the normal method you can't search for multiple class names but you can using css selector [class=] --->
		<cfif find(" ", arguments.className) GT 0 >
			<cfset sSearchString="#arguments.onlyElementsOfTag#[class='#arguments.className#']" />
		</cfif>

		<cfset oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = sSearchString,
			locateUsing = "cssSelector"
		) />

		<cfif arguments.getLocator >
			<cfreturn oLocator />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator, multiple=true) />
		<cfelse>
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="name" returntype="any" access="public" hint="Search for and retrieve elements based on name-attribute." >
		<cfargument name="name" type="string" required="yes" hint="The name of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain name, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "[name='#arguments.name#']" />
		<cfset var oLocator = "" />

		<cfif len(arguments.onlyElementsOfTag) GT 0 >
			<cfset sSearchString="#arguments.onlyElementsOfTag##sSearchString#" />
		</cfif>

		<cfset oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = sSearchString,
			locateUsing = "cssSelector"
		) />

		<cfif arguments.getLocator >
			<cfreturn oLocator />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator, multiple=true) />
		<cfelse>
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<!--- http://stackoverflow.com/questions/38240763/xpath-difference-between-dot-and-text --->
	<cffunction name="textEquals" returntype="any" access="public" hint="Search for and retrieve elements based on the text content being the exact value you search for." >
		<cfargument name="text" type="string" required="yes" hint="The text content of the element you want to search for. Only an element whose content is EXACTLY what you pass which be retrieved."  />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="*" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with certain text content, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "//#arguments.onlyElementsOfTag#[normalize-space(.)='#arguments.text#']" />
		<cfset var oLocator = "" />

		<cfset oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = sSearchString,
			locateUsing = "xpath"
		) />

		<cfif arguments.getLocator >
			<cfreturn oLocator />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator, multiple=true) />
		<cfelse>
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<!--- http://stackoverflow.com/questions/3655549/xpath-containstext-some-string-doesnt-work-when-used-with-node-with-more --->
	<cffunction name="textContains" returntype="any" access="public" hint="Search for and retrieve elements based on the text content containing the value you search for." >
		<cfargument name="text" type="string" required="yes" hint="The text content of the element you want to search for. An element whose content contains what you pass which be retrieved. Great for partial searches." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="*" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with certain text content, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "//#arguments.onlyElementsOfTag#[text()[contains(.,'#arguments.text#')]]" />
		<cfset var oLocator = "" />

		<cfset oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = sSearchString,
			locateUsing = "xpath"
		) />

		<cfif arguments.getLocator >
			<cfreturn oLocator />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator, multiple=true) />
		<cfelse>
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="inputType" returntype="any" access="public" hint="Search for and retrieve input elements based on the type-attribute." >
		<cfargument name="type" type="string" required="yes" hint="The type of input element you want to search for." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "input[type='#arguments.type#']" />
		<cfset var oLocator = "" />

		<cfset oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = sSearchString,
			locateUsing = "cssSelector"
		) />

		<cfif arguments.getLocator >
			<cfreturn oLocator />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator, multiple=true) />
		<cfelse>
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="value" returntype="any" access="public" hint="Search for and retrieve elements based on the value-attribute." >
		<cfargument name="value" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="*" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with certain text content, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "#arguments.onlyElementsOfTag#[value='#arguments.value#']" />
		<cfset var oLocator = "" />

		<cfset oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = sSearchString,
			locateUsing = "cssSelector"
		) />

		<cfif arguments.getLocator >
			<cfreturn oLocator />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator, multiple=true) />
		<cfelse>
			<cfset ReturnData = variables.oWrappedBrowser.getElement(locator=oLocator) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="attributeStartsWith" returntype="any" access="public" hint="Search for and retrieve elements that start with a certain value for a specific attribute." >
		<cfargument name="attribute" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="value" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain value, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var stGetByAttributeAndOperatorArguments = {
			attribute=arguments.attribute,
			value=arguments.value,
			operator="^",
			onlyElementsOfTag=arguments.onlyElementsOfTag,
			multiple=arguments.multiple,
			getLocator=arguments.getLocator
		} />

		<cfreturn getByAttributeAndOperator(argumentCollection = stGetByAttributeAndOperatorArguments) />
	</cffunction>

	<cffunction name="attributeEndsWith" returntype="any" access="public" hint="Search for and retrieve elements that end with a certain value for a specific attribute" >
		<cfargument name="attribute" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="value" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain value, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var stGetByAttributeAndOperatorArguments = {
			attribute=arguments.attribute,
			value=arguments.value,
			operator="$",
			onlyElementsOfTag=arguments.onlyElementsOfTag,
			multiple=arguments.multiple,
			getLocator=arguments.getLocator
		} />

		<cfreturn getByAttributeAndOperator(argumentCollection = stGetByAttributeAndOperatorArguments) />
	</cffunction>

	<cffunction name="attributeContains" returntype="any" access="public" hint="Search for and retrieve elements that contain a certain value for a specific attribute" >
		<cfargument name="attribute" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="value" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain value, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />
		<cfargument name="getLocator" type="boolean" required="no" default="false" hint="Returns the Locator used in the search instead of elements." />

		<cfset var stGetByAttributeAndOperatorArguments = {
			attribute=arguments.attribute,
			value=arguments.value,
			operator="*",
			onlyElementsOfTag=arguments.onlyElementsOfTag,
			multiple=arguments.multiple,
			getLocator=arguments.getLocator
		} />

		<cfreturn getByAttributeAndOperator(argumentCollection = stGetByAttributeAndOperatorArguments) />
	</cffunction>

</cfcomponent>