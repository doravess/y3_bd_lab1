using Microsoft.Data.SqlClient;
using StoreApp_lab1_bd.Data;
using StoreApp_lab1_bd.Models;

namespace StoreApp_lab1_bd.Repositories
{
    public class ProductRepository : IRepository<Product>
    {
        private readonly ApplicationDbContext _context;

        public ProductRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Product>> GetAllAsync()
        {
            return await _context.ExecuteStoredProcedureAsync<Product>("GetAllProducts");
        }

        public async Task<Product> GetByIdAsync(int id)
        {
            var result = await _context.ExecuteStoredProcedureAsync<Product>(
                "GetProductById",
                new SqlParameter("@Id", id)
            );
            return result.FirstOrDefault();
        }

        public async Task AddAsync(Product entity)
        {
            await _context.ExecuteNonQueryStoredProcedureAsync(
                "AddProduct",
                new SqlParameter("@Name", entity.Name),
                new SqlParameter("@BasePrice", entity.BasePrice),
                new SqlParameter("@CategoryId", (object?)entity.CategoryId ?? DBNull.Value),
                new SqlParameter("@SupplierId", (object?)entity.SupplierId ?? DBNull.Value),
                new SqlParameter("@Details", (object?)entity.Details ?? DBNull.Value)
            );
        }

        public async Task UpdateAsync(Product entity)
        {
            await _context.ExecuteNonQueryStoredProcedureAsync(
                "UpdateProduct",
                new SqlParameter("@Id", entity.Id),
                new SqlParameter("@Name", entity.Name),
                new SqlParameter("@BasePrice", entity.BasePrice),
                new SqlParameter("@CategoryId", (object?)entity.CategoryId ?? DBNull.Value),
                new SqlParameter("@SupplierId", (object?)entity.SupplierId ?? DBNull.Value),
                new SqlParameter("@Details", (object?)entity.Details ?? DBNull.Value)
            );
        }

        public async Task DeleteAsync(int id)
        {
            await _context.ExecuteNonQueryStoredProcedureAsync(
                "DeleteProduct",
                new SqlParameter("@Id", id)
            );
        }
    }
}