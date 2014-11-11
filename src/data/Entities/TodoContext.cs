namespace TodoList.Data.Entities
{
    public class TodoContext : DbContext {
        public TodoContext() : base( "name=todosdb") { }

        public DbSet<Todo> Todos { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Todo>()
                .ToTable("Todos");

            base.OnModelCreating(modelBuilder);
        }
    }
}