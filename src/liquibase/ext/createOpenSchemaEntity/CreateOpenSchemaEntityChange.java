package liquibase.ext.createOpenSchemaEntity;

import liquibase.change.AbstractChange;
import liquibase.statement.DatabaseFunction;
import liquibase.statement.SqlStatement;
import liquibase.database.Database;
import liquibase.statement.core.InsertStatement;
import liquibase.change.ChangeMetaData;

public class CreateOpenSchemaEntityChange extends AbstractChange {
    private Integer id;
    private String directory;
    private String parent;
    private String qualifiedName;
    private String name;
/*    private SampleChild child;
    private SampleChild child2;
*/
    public CreateOpenSchemaEntityChange() {
        super("createOpenSchemaEntity", "Create a new open-schema entity", ChangeMetaData.PRIORITY_DEFAULT);
/*
        setDirectory("Prime");
        setParent("Any");
*/
    }

    public String getConfirmationMessage() {
        return "createOpenSchemaEntity executed";
    }

    public SqlStatement[] generateStatements(Database database) {
        return new SqlStatement[]{
            new InsertStatement(null, "entity_type")
                .addColumnValue("directory_id", getDirectoryValue())
                .addColumnValue("parent_id", getParentValue())
                .addColumnValue("entity_type_id", getId())
                .addColumnValue("qualified_name", getQualifiedName())
                .addColumnValue("name", getName())
        };
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getParent() {
        return parent;
    }

    public Object getParentValue() {
        final String value = getParent();
        // the "double select" is used for lookup due to MySQL error "You can't specify target table 'entity_type' for update in FROM clause"
        return new DatabaseFunction(value == null ? "NULL" : String.format("(select entity_type_id from (select entity_type_id from entity_type where qualified_name = '%s') as parent_id)", value));
    }

    public void setParent(String name) {
        this.parent = name;
    }

    public String getDirectory() {
        return directory;
    }

    /**
     * Obtain the directory_id column value
     * @return A select statement that will find the directory ID in the directory table or through the parent of the entity
     */
    public Object getDirectoryValue() {
        final String value = getDirectory();
        // the "double select" is used for lookup due to MySQL error "You can't specify target table 'entity_type' for update in FROM clause"
        return value != null ?
                new DatabaseFunction(String.format("(select directory_id from directory where qualified_name = '%s')", value)) :
                new DatabaseFunction(String.format("(select directory_id from (select directory_id from entity_type where qualified_name = '%s') as parent_directory_id)", getParent()));
    }

    public void setDirectory(String name) {
        this.directory = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getQualifiedName() {
        return qualifiedName == null ? (parent == null ? "" : parent + ".") + name : qualifiedName;
    }

    public void setQualifiedName(String qualifiedName) {
        this.qualifiedName = qualifiedName;
    }

/*    public SampleChild getChild() {
        return child;
    }

    public SampleChild getChild2() {
        return child2;
    }

    public SampleChild createSampleSubValue() {
        child = new SampleChild();
        return child;
    }

    public SampleChild createOtherSampleValue() {
        child2 = new SampleChild();
        return child2;
    }
*/}