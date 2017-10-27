<cfcomponent output="false" hint="An interface that is injected into Browser.cfc (composition). It contains shorthand methods designed to easily grab elements with a minimum of fuss using specific, commonly used attributes such as id, class, title, name etc. This means that searching for attributes that could have values shared among multiple elements, only the first element encountered in the DOM will be retrieved (unless you specify the Multiple-argument). All the methods (with a few exceptions) operate using cssSelectors because I find them really powerful and you can get quite specific in your searches." >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oBrowser = "" />

	<!--- PRIVATE METHODS --->

	<cffunction name="setBrowser" returntype="void" access="private" >
		<cfargument name="data" type="Components.Browser" required="yes" />

		<cfset oBrowser = arguments.data />
	</cffunction>

	<cffunction name="getBrowser" returntype="Components.Browser" access="private" >
		<cfreturn oBrowser />
	</cffunction>

	<cffunction name="init" returntype="Components.ElementLocator" access="public" hint="Constructor" >
		<cfargument name="browserReference" type="Components.Browser" required="true" />

		<cfset setBrowser(Data=arguments.browserReference) />

		<cfreturn this />
	</cffunction>

	<cffunction name="getByAttributeAndOperator" returntype="any" access="private" hint="" >
		<cfargument name="attribute" type="string" required="yes" hint="" />
		<cfargument name="value" type="string" required="yes" hint="" />
		<cfargument name="operator" type="string" required="yes" hint="" />
		<cfargument name="onlyElementsOfTag" type="string" required="yes" hint="" />
		<cfargument name="multiple" type="boolean" required="yes" hint="" />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "" />

		<cfif len(arguments.value) IS 0 OR arguments.value IS " " >
			<cfthrow message="Error fetching element by attribute" detail="Argument 'value' is empty" />
		</cfif>

		<cfif len(arguments.attribute) IS 0 OR arguments.attribute IS " " >
			<cfthrow message="Error fetching element by attribute" detail="Argument 'attribute' is empty" />
		</cfif>

		<cfset sSearchString = "#trim(arguments.onlyElementsOfTag)#[#trim(arguments.attribute)##arguments.operator#='#arguments.value#']" />

		<cfif arguments.multiple >
			<cfset ReturnData = getBrowser().getElements(
				SearchFor=sSearchString,
				LocateUsing=["cssSelector"]
			) />
		<cfelse>
			<cfset ReturnData = getBrowser().getElement(
				SearchFor=sSearchString,
				LocateUsing=["cssSelector"]
			) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<!--- PUBLIC METHODS --->

	<cffunction name="title" returntype="any" access="public" hint="Search for and retrieve elements based on the title-attribute." >
		<cfargument name="title" type="string" required="yes" hint="The title of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain title, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "[title='#arguments.title#']" />

		<cfif len(arguments.onlyElementsOfTag) GT 0 >
			<cfset sSearchString = "#arguments.onlyElementsOfTag#[title='#arguments.title#']" />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = getBrowser().getElements(
				SearchFor=sSearchString,
				LocateUsing=["cssSelector"]
			) />
		<cfelse>
			<cfset ReturnData = getBrowser().getElement(
				SearchFor=sSearchString,
				LocateUsing=["cssSelector"]
			) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="id" returntype="Components.Element" access="public" hint="Search for and retrieve a single element based on its id-attribute." >
		<cfargument name="id" type="string" required="yes" hint="The id of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain id, rather than any element." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "###arguments.id#" />

		<cfif len(arguments.onlyElementsOfTag) GT 0 >
			<cfset sSearchString = "#arguments.onlyElementsOfTag##sSearchString#" />
		</cfif>

		<cfset ReturnData = getBrowser().getElement(
			SearchFor=sSearchString,
			LocateUsing=["cssSelector"]
		) />

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="class" returntype="any" access="public" hint="Search for and retrieve elements based on the className-attribute." >
		<cfargument name="className" type="string" required="yes" hint="The class name or names you want to search for. You can search for both single and multiple classes, separated by spaces." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain class name (or names), rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = ".#arguments.className#" />

		<!--- With the normal method you can't search for multiple class names but you can using css selector [class=] --->
		<cfif find(" ", arguments.className) GT 0 >

			<cfif len(arguments.onlyElementsOfTag) GT 0 >
				<cfset sSearchString="#arguments.onlyElementsOfTag#[class='#arguments.className#']" />
			<cfelse>
				<cfset sSearchString="[class='#arguments.className#']" />
			</cfif>

		<cfelse>
			<cfif len(arguments.onlyElementsOfTag) GT 0 >
				<cfset sSearchString="#arguments.onlyElementsOfTag##sSearchString#" />
			</cfif>
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = getBrowser().getElements(
				SearchFor=sSearchString,
				LocateUsing=["cssSelector"]
			) />
		<cfelse>
			<cfset ReturnData = getBrowser().getElement(
				SearchFor=sSearchString,
				LocateUsing=["cssSelector"]
			) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="name" returntype="any" access="public" hint="Search for and retrieve elements based on name-attribute." >
		<cfargument name="name" type="string" required="yes" hint="The name of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain name, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "[name='#arguments.name#']" />

		<cfif len(arguments.onlyElementsOfTag) GT 0 >
			<cfset sSearchString="#arguments.onlyElementsOfTag##sSearchString#" />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = getBrowser().getElements(
				SearchFor=sSearchString,
				LocateUsing=["cssSelector"]
			) />
		<cfelse>
			<cfset ReturnData = getBrowser().getElement(
				SearchFor=sSearchString,
				LocateUsing=["cssSelector"]
			) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<!--- http://stackoverflow.com/questions/38240763/xpath-difference-between-dot-and-text --->
	<cffunction name="textEquals" returntype="any" access="public" hint="Search for and retrieve input elements based on the text content being the exact value you search for." >
		<cfargument name="text" type="string" required="yes" hint="The text content of the element you want to search for. Only an element whose content is EXACTLY what you pass which be retrieved."  />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with certain text content, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "//*[normalize-space(.)='#arguments.text#']" />

		<cfif len(arguments.onlyElementsOfTag) GT 0 >
			<cfset sSearchString= "//#arguments.onlyElementsOfTag#[normalize-space(.)='#arguments.text#']" />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = getBrowser().getElements(
				SearchFor=sSearchString,
				LocateUsing=["xpath"]
			) />
		<cfelse>
			<cfset ReturnData = getBrowser().getElement(
				SearchFor=sSearchString,
				LocateUsing=["xpath"]
			) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<!--- http://stackoverflow.com/questions/3655549/xpath-containstext-some-string-doesnt-work-when-used-with-node-with-more --->
	<cffunction name="textContains" returntype="any" access="public" hint="Search for and retrieve input elements based on the text content containing the value you search for." >
		<cfargument name="text" type="string" required="yes" hint="The text content of the element you want to search for. An element whose content contains what you pass which be retrieved. Great for partial searches." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with certain text content, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "//*[text()[contains(.,'#arguments.text#')]]" />

		<cfif len(arguments.onlyElementsOfTag) GT 0 >
			<cfset sSearchString= "//#arguments.onlyElementsOfTag#[text()[contains(.,'#arguments.text#')]]" />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = getBrowser().getElements(
				SearchFor=sSearchString,
				LocateUsing=["xpath"]
			) />
		<cfelse>
			<cfset ReturnData = getBrowser().getElement(
				SearchFor=sSearchString,
				LocateUsing=["xpath"]
			) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="inputType" returntype="any" access="public" hint="Search for and retrieve input elements based on the type-attribute." >
		<cfargument name="type" type="string" required="yes" hint="The type of input element you want to search for." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />

		<cfif arguments.multiple >
			<cfset ReturnData = getBrowser().getElements(
				SearchFor="input[type='#arguments.type#']",
				LocateUsing=["cssSelector"]
			) />
		<cfelse>
			<cfset ReturnData = getBrowser().getElement(
				SearchFor="input[type='#arguments.type#']",
				LocateUsing=["cssSelector"]
			) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="value" returntype="any" access="public" hint="Search for and retrieve elements based on the value-attribute." >
		<cfargument name="value" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain value, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "[value='#arguments.value#']" />

		<cfif len(arguments.onlyElementsOfTag) GT 0 >
			<cfset sSearchString="#arguments.onlyElementsOfTag##sSearchString#" />
		</cfif>

		<cfif arguments.multiple >
			<cfset ReturnData = getBrowser().getElements(
				SearchFor=sSearchString,
				LocateUsing=["cssSelector"]
			) />
		<cfelse>
			<cfset ReturnData = getBrowser().getElement(
				SearchFor=sSearchString,
				LocateUsing=["cssSelector"]
			) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="attributeStartsWith" returntype="any" access="public" hint="Search for and retrieve elements that start with a certain value for a specific attribute." >
		<cfargument name="attribute" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="value" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain value, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var stGetByAttributeAndOperatorArguments = {
			attribute=arguments.attribute,
			value=arguments.value,
			operator="^",
			onlyElementsOfTag=arguments.onlyElementsOfTag,
			multiple=arguments.multiple
		} />

		<cfreturn getByAttributeAndOperator(argumentCollection = stGetByAttributeAndOperatorArguments) />
	</cffunction>

	<cffunction name="attributeEndsWith" returntype="any" access="public" hint="Search for and retrieve elements that end with a certain value for a specific attribute" >
		<cfargument name="attribute" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="value" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain value, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var stGetByAttributeAndOperatorArguments = {
			attribute=arguments.attribute,
			value=arguments.value,
			operator="$",
			onlyElementsOfTag=arguments.onlyElementsOfTag,
			multiple=arguments.multiple
		} />

		<cfreturn getByAttributeAndOperator(argumentCollection = stGetByAttributeAndOperatorArguments) />
	</cffunction>

	<cffunction name="attributeContains" returntype="any" access="public" hint="Search for and retrieve elements that contain a certain value for a specific attribute" >
		<cfargument name="attribute" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="value" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="onlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain value, rather than any element." />
		<cfargument name="multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var stGetByAttributeAndOperatorArguments = {
			attribute=arguments.attribute,
			value=arguments.value,
			operator="*",
			onlyElementsOfTag=arguments.onlyElementsOfTag,
			multiple=arguments.multiple
		} />

		<cfreturn getByAttributeAndOperator(argumentCollection = stGetByAttributeAndOperatorArguments) />
	</cffunction>

</cfcomponent>