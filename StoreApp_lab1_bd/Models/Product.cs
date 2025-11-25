namespace StoreApp_lab1_bd.Models
{
    public class Product
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public decimal BasePrice { get; set; }
        public int? CategoryId { get; set; }
        public int? SupplierId { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int? UpdatedBy { get; set; }
        public string? Details { get; set; }
    }
}