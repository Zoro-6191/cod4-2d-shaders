float toRange( float originalStart, float originalEnd,  // original range
               float newStart,      float newEnd,       // desired range
               float value)                             // value to convert
{
    float originalDiff = originalEnd - originalStart;
    float newDiff = newEnd - newStart;
    float ratio = newDiff / originalDiff;
    float newProduct = value * ratio;
    float finalValue = newProduct + newStart;
    return finalValue; 
}