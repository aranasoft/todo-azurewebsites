using System;

namespace TodoList.Data.Migrations
{
    public partial class InitialMigration : DbMigration
    {
        public override void Up()
        {
            CreateTable(
                "dbo.Todos",
                c => new
                    {
                        Id = c.Int(nullable: false, identity: true),
                        Completed = c.Boolean(nullable: false),
                        Content = c.String(),
                        Points = c.Int(nullable: false),
                    })
                .PrimaryKey(t => t.Id);
            
        }
        
        public override void Down()
        {
            DropTable("dbo.Todos");
        }
    }
}
