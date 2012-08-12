package liquibase.ext.createOpenSchemaEntity;

import liquibase.change.AbstractChange;
import liquibase.statement.DatabaseFunction;
import liquibase.statement.SqlStatement;
import liquibase.database.Database;
import liquibase.statement.core.InsertStatement;
import liquibase.change.ChangeMetaData;

import java.util.ArrayList;
import java.util.List;

public class CreateOpenSchemaEntityChange extends AbstractChange {
    private Integer id;
    private String directory;
    private String parent;
    private String qualifiedName;
    private String name;
    private List<Attribute> attributes;

    protected class Attribute
    {
        private int position;
        private Integer id;
        private String name;
        private String qualifiedName;
        private String type;

        public Attribute(int position) {
            this.position = position;
        }

        public Integer getId() {
            return id == null ? CreateOpenSchemaEntityChange.this.getId() + position : id;
        }

        public void setId(Integer id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public Object getTypeValue() {
            return new DatabaseFunction(String.format("(select value_type_id from value_type where qualified_name = '%s')", getType()));
        }

        public String getQualifiedName() {
            return qualifiedName == null ? (CreateOpenSchemaEntityChange.this.getQualifiedName() + ".") + name : qualifiedName;
        }

        public void setQualifiedName(String qualifiedName) {
            this.qualifiedName = qualifiedName;
        }

        public SqlStatement getSqlStatement() {
            return new InsertStatement(null, "attr_type")
                    .addColumnValue("attr_type_id", getId())
                    .addColumnValue("entity_type_id", CreateOpenSchemaEntityChange.this.getId())
                    .addColumnValue("value_type_id", getTypeValue())
                    .addColumnValue("qualified_name", getQualifiedName())
                    .addColumnValue("name", getName());
        }
    }

    public CreateOpenSchemaEntityChange() {
        super("createOpenSchemaEntity", "Create a new open-schema entity", ChangeMetaData.PRIORITY_DEFAULT);
        attributes = new ArrayList<Attribute>();
    }

    public String getConfirmationMessage() {
        return "createOpenSchemaEntity executed";
    }

    public SqlStatement[] generateStatements(Database database) {
        final List<SqlStatement> result = new ArrayList<SqlStatement>();
        result.add(new InsertStatement(null, "entity_type")
                .addColumnValue("directory_id", getDirectoryValue())
                .addColumnValue("parent_id", getParentValue())
                .addColumnValue("entity_type_id", getId())
                .addColumnValue("qualified_name", getQualifiedName())
                .addColumnValue("name", getName())
        );
        for(final Attribute a : attributes)
        {
            result.add(a.getSqlStatement());
        }
        return result.toArray(new SqlStatement[result.size()]);
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

    public Attribute createAttribute() {
        Attribute attr = new Attribute(attributes.size());
        attributes.add(attr);
        return attr;
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