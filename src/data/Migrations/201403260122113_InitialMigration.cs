using System;
using System.Data.Entity.Migrations;

namespace TodoList.Data.Migrations {
    public partial class InitialMigration : DbMigration {
        public override void Up() {
            CreateTable(
                "dbo.Todos",
                c => new {
                    Id = c.Int(false, true),
                    Completed = c.Boolean(false),
                    Content = c.String(),
                    Points = c.Int(false),
                })
                .PrimaryKey(t => t.Id);
        }

        public override void Down() {
            DropTable("dbo.Todos");
        }
    }
}