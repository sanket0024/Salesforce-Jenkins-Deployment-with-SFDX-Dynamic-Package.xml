# Developer: Sanket Mathur

#/usr/bin/env bash
 
OPTIND=1
echo Removing package.xml
rm package.xml
echo Creating package.xml
touch package.xml
echo '<Package></Package>' > package.xml

git diff-tree --no-commit-id --name-only --diff-filter=ACMRTUXB -t -r HEAD~1 HEAD | \
while read -r DIFFS; do
	case "$DIFFS"
	in
		*.cls*) TYPENAME="ApexClass";;
		*.component*) TYPENAME="ApexComponent";;
		*.page*) TYPENAME="ApexPage";;
		*.trigger*) TYPENAME="ApexTrigger";;
		*.assignmentRules*) TYPENAME="AssignmentRules";;
		*/aura/*/*) TYPENAME="UNKNOWN TYPE";;
		*/aura/*) TYPENAME="AuraDefinitionBundle";;
		*/applications*.app*) TYPENAME="CustomApplication";;
		*.customApplicationComponent*) TYPENAME="CustomApplicationComponent";;
		*/objects/*/*) TYPENAME="UNKNOWN TYPE";;
		*/objects/*) TYPENAME="CustomObject";;
		*.customPermission*) TYPENAME="CustomPermission";;
		*.tab*) TYPENAME="CustomTab";;
		*.layout*) TYPENAME="Layout";;
		*.permissionset*) TYPENAME="PermissionSet";;
		*.profile*) TYPENAME="Profile";;
		*.resource*) TYPENAME="StaticResource";;
		*.workflow*) TYPENAME="Workflow";;
		*) TYPENAME="UNKNOWN TYPE";;
	esac
	if [ "$TYPENAME" != "UNKNOWN TYPE" ]
	then
		case "$DIFFS"
		in
			force-app/main/default/aura/*)  ENTITY="${DIFFS#force-app/main/default/aura/}" ENTITY="${ENTITY%/*}";;
			*) ENTITY=$(basename "$DIFFS");;
		esac

		ENTITY=${ENTITY%%\.*}

		if grep -F "$TYPENAME" package.xml
		then
			xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" package.xml
		else
			xmlstarlet ed -L -s /Package -t elem -n types -v "" package.xml
			xmlstarlet ed -L -s '/Package/types[not(*)]' -t elem -n name -v "$TYPENAME" package.xml
			xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" package.xml
		fi
	fi
done

xmlstarlet ed -L -i /Package -t attr -n xmlns -v "http://soap.sforce.com/2006/04/metadata" package.xml

echo "----------Package.xml file---------" 
cat package.xml
tar cf - package.xml | (cd force-app/main/default; tar xf -)
