<cfcomponent output="false" modifier="final" hint="Utility component for creating Selenium objects based on how the jar-files are made available to your application. By default, if you instantiate it with no parameters, it will simply use createObject() with no additional arguments" >
	<!---
		Creation strategies:
		0 - Default, use createObject with no additional parameters. User is responsible for making the Selenium jars available to CF/Lucee somehow
		1 - Use Mark Mandel's excellent javaloader
		2 - Use the bundle name-parameter of createObject to pass the full path to the folder where the Selenium jars are available
	--->

	<cfset variables.creationStrategy = 0 />
	<cfset variables.javaLoader = nullValue() />
	<cfset variables.seleniumJarsPath = "" />

	<cffunction name="init" returntype="SeleniumObjectFactory" access="public" hint="Constructor" >
		<cfargument name="javaloaderInstance" type="any" required="false" hint="Instance of Mark Mandel's JavaLoader. If you for some reason pass both arguments, then the Javaloader takes precedence." />
		<cfargument name="jarFolder" type="string" required="false" hint="Full path to folder where all the Selenium jars are located. Does not work in ACF." />

		<cfif structKeyExists(arguments, "javaloaderInstance") AND isObject(arguments.javaloaderInstance) >
			<cfset variables.javaLoader = arguments.javaloaderInstance />
			<cfset variables.creationStrategy = 1 />
		<cfelseif structKeyExists(arguments, "jarFolder") AND directoryExists(arguments.jarFolder) >
			<cfset variables.seleniumJarsPath = arguments.jarFolder />
			<cfset variables.creationStrategy = 2 />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="getStrategy" returntype="string" access="public" hint="Returns the strategy used for creating Selenium objects" >
		<cfswitch expression=#variables.creationStrategy# >
			<cfcase value="0">
				<cfreturn "STANDARD" />
			</cfcase>
			<cfcase value="1">
				<cfreturn "JAVALOADER" />
			</cfcase>
			<cfcase value="2">
				<cfreturn "JAR_PATH" />
			</cfcase>

			<cfdefaultcase>
				<cfreturn "ERROR" />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="get" returntype="any" access="public" hint="Creates and returns a given Selenium object. The returned object is a static handle, so you still have to call init() on it yourself." >
		<cfargument name="class" type="string" required="true" hint="Name of the Selenium Java-class you wish to create an instance of." />

		<cfswitch expression=#variables.creationStrategy# >
			<cfcase value="0">
				<cfreturn createObject("java", arguments.class) />
			</cfcase>
			<cfcase value="1">
				<cfreturn variables.javaLoader.create(arguments.class) />
			</cfcase>
			<cfcase value="2">
				<cfreturn createObject("java", arguments.class, variables.seleniumJarsPath) />
			</cfcase>

			<cfdefaultcase>
				<cfthrow message="Error getting Selenium object" message="The creation strategy is incorrect: #variables.creationStrategy#" />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

</cfcomponent>