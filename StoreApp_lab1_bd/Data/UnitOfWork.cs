using StoreApp_lab1_bd.Repositories;
using YourProject.Repositories;

namespace StoreApp_lab1_bd.Data
{
    public class UnitOfWork : IDisposable
    {
        private readonly ApplicationDbContext _context;

        public ProductRepository Products { get; }
        public OrderRepository Stores { get; }
        public OrderItemRepository ProductStores { get; }

        public UnitOfWork(ApplicationDbContext context)
        {
            _context = context;

            Products = new ProductRepository(_context);
            Stores = new OrderRepository(_context);
            ProductStores = new OrderItemRepository(_context);
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }

}
