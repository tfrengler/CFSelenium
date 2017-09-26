<cfcomponent output="false" hint="An 'interface'/extension that is injected into Browser.cfc. It contains shorthand methods designed to easily grab elements with a minimum of fuss using specific, commonly used attributes such as id, class, title, name etc. This means that searching for attributes that could have values shared among multiple elements, only the first element encountered in the DOM will be retrieved (unless you specify the Multiple-argument). All the methods (with a few exceptions) operate using cssSelectors because I find them really powerful and you can get quite specific in your searches." >
<cfprocessingdirective pageencoding="utf-8" />

	<!--- ADD THE POSSIBILITY TO SEARCH FOR: BEGINS WITH, ENDS WITH, CONTAINS. MAYBE ALSO LIMITED TO ELEMENT --->

	<cfset oBrowser = "" />

	<cffunction name="setBrowser" returntype="void" access="private" >
		<cfargument name="Data" type="Components.Browser" required="yes" />

		<cfset oBrowser = arguments.Data />
	</cffunction>

	<cffunction name="getBrowser" returntype="Components.Browser" access="private" >
		<cfreturn oBrowser />
	</cffunction>

	<cffunction name="init" returntype="Components.ElementLocator" access="public" hint="Constructor" >
		<cfargument name="BrowserReference" type="Components.Browser" required="true" />

		<cfset setBrowser(Data=arguments.BrowserReference) />

		<cfreturn this />
	</cffunction>

	<!--- PUBLIC METHODS --->

	<cffunction name="title" returntype="any" access="public" hint="Search for and retrieve elements based on the title-attribute." >
		<cfargument name="Title" type="string" required="yes" hint="The title of the element you want to search for." />
		<cfargument name="OnlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain title, rather than any element." />
		<cfargument name="Multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "[title='#arguments.Title#']" />

		<cfif len(arguments.OnlyElementsOfTag) GT 0 >
			<cfset sSearchString = "#arguments.OnlyElementsOfTag#[title='#arguments.Title#']" />
		</cfif>

		<cfif arguments.Multiple >
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
		<cfargument name="Id" type="string" required="yes" hint="The id of the element you want to search for." />
		<cfargument name="OnlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain id, rather than any element." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "###arguments.Id#" />

		<cfif len(arguments.OnlyElementsOfTag) GT 0 >
			<cfset sSearchString = "#arguments.OnlyElementsOfTag##sSearchString#" />
		</cfif>

		<cfset ReturnData = getBrowser().getElement(
			SearchFor=sSearchString,
			LocateUsing=["cssSelector"]
		) />

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="class" returntype="any" access="public" hint="Search for and retrieve elements based on the className-attribute." >
		<cfargument name="ClassName" type="string" required="yes" hint="The class name or names you want to search for. You can search for both single and multiple classes, separated by spaces." />
		<cfargument name="OnlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain class name (or names), rather than any element." />
		<cfargument name="Multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = ".#arguments.ClassName#" />

		<!--- With the normal method you can't search for multiple class names but you can using css selector [class=] --->
		<cfif find(" ", arguments.ClassName) GT 0 >

			<cfif len(arguments.OnlyElementsOfTag) GT 0 >
				<cfset sSearchString="#arguments.OnlyElementsOfTag#[class='#arguments.ClassName#']" />
			<cfelse>
				<cfset sSearchString="[class='#arguments.ClassName#']" />
			</cfif>

		<cfelse>
			<cfif len(arguments.OnlyElementsOfTag) GT 0 >
				<cfset sSearchString="#arguments.OnlyElementsOfTag##sSearchString#" />
			</cfif>
		</cfif>

		<cfif arguments.Multiple >
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
		<cfargument name="Name" type="string" required="yes" hint="The name of the element you want to search for." />
		<cfargument name="OnlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain name, rather than any element." />
		<cfargument name="Multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "[name='#arguments.Name#']" />

		<cfif len(arguments.OnlyElementsOfTag) GT 0 >
			<cfset sSearchString="#arguments.OnlyElementsOfTag##sSearchString#" />
		</cfif>

		<cfif arguments.Multiple >
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
		<cfargument name="Text" type="string" required="yes" hint="The text content of the element you want to search for. Only an element whose content is EXACTLY what you pass which be retrieved."  />
		<cfargument name="OnlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with certain text content, rather than any element." />
		<cfargument name="Multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "//*[text()='#arguments.Text#']" />

		<cfif len(arguments.OnlyElementsOfTag) GT 0 >
			<cfset sSearchString= "//#arguments.OnlyElementsOfTag#[text()='#arguments.Text#']" />
		</cfif>

		<cfif arguments.Multiple >
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
		<cfargument name="Text" type="string" required="yes" hint="The text content of the element you want to search for. An element whose content contains what you pass which be retrieved. Great for partial searches." />
		<cfargument name="OnlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with certain text content, rather than any element." />
		<cfargument name="Multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "//*[text()[contains(.,'#arguments.Text#')]]" />

		<cfif len(arguments.OnlyElementsOfTag) GT 0 >
			<cfset sSearchString= "//#arguments.OnlyElementsOfTag#[text()[contains(.,'#arguments.Text#')]]" />
		</cfif>

		<cfif arguments.Multiple >
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
		<cfargument name="Type" type="string" required="yes" hint="The type of input element you want to search for." />
		<cfargument name="Multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />

		<cfif arguments.Multiple >
			<cfset ReturnData = getBrowser().getElements(
				SearchFor="input[type='#arguments.Type#']",
				LocateUsing=["cssSelector"]
			) />
		<cfelse>
			<cfset ReturnData = getBrowser().getElement(
				SearchFor="input[type='#arguments.Type#']",
				LocateUsing=["cssSelector"]
			) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="value" returntype="any" access="public" hint="Search for and retrieve elements based on the value-attribute." >
		<cfargument name="Value" type="string" required="yes" hint="The value of the element you want to search for." />
		<cfargument name="OnlyElementsOfTag" type="string" required="no" default="" hint="Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain value, rather than any element." />
		<cfargument name="Multiple" type="boolean" required="no" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var sSearchString = "[value='#arguments.Value#']" />

		<cfif len(arguments.OnlyElementsOfTag) GT 0 >
			<cfset sSearchString="#arguments.OnlyElementsOfTag##sSearchString#" />
		</cfif>

		<cfif arguments.Multiple >
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

</cfcomponent>