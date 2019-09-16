
CD_CASE_SIZE = [142, 125, 10];

HOLDER_RADIUS = 5;

COVER_SIZE = HOLDER_RADIUS + 25;
COVER_THICKNESS = 3;

// https://en.wikipedia.org/wiki/Optical_disc_packaging#Jewel_case
module JewelCase()
{
    color(rands(0, 1.0, 3))
    cube(CD_CASE_SIZE);
}

function hypotenuse(a, b) = sqrt(a * a + b * b);

module Holder(backingThickness)
{
    EXTRA_Z_SPACE = 2; // Space between CD jewel case and holder cover
    height = CD_CASE_SIZE[2] + backingThickness + EXTRA_Z_SPACE;

    color("silver")
    union()
    {
        // Stem
        //cylinder(h=height, r=HOLDER_RADIUS);

        // Stem - Spiky
        s = hypotenuse(HOLDER_RADIUS, HOLDER_RADIUS);
        for (theta = [15 : 15 : 90 - 15])
        {
            rotate([0, 0,  theta])
            translate([0, 0, height / 2])
            cube([s, s, height], center=true);
        }

        // Cover
        rotate([0, 0, 45])
        translate([0, 0, height + COVER_THICKNESS / 2])
        cube([COVER_SIZE, COVER_SIZE, COVER_THICKNESS], center=true);

        // Weird extra cover
        //translate([0, 0, height + COVER_THICKNESS / 2])
        //cube([COVER_SIZE, COVER_SIZE, COVER_THICKNESS], center=true);

        // Plates to hold and separate CD jewel cases
        w = HOLDER_RADIUS; //w = 1;
        h = height - backingThickness;
        translate([0, 0, h/2 + backingThickness])
        {
            cube([COVER_SIZE, w, h], center=true);
            cube([w, COVER_SIZE, h], center=true);
        }
    }
}

module ArrayOfJewelCases(numCDX, numCDY, spacing)
{
    for (x = [0 : 1 : numCDX - 1])
    {
        for (y = [0 : 1 : numCDY - 1])
        {
            xPos = x * (CD_CASE_SIZE[0] + spacing);
            yPos = y * (CD_CASE_SIZE[1] + spacing);
            translate([xPos, yPos, 0])
            JewelCase();
        }
    }
}

module ArrayOfHolders(numCDX, numCDY, spacing, backingThickness)
{
    for (x = [0 : 1 : numCDX])
    {
        for (y = [0 : 1 : numCDY])
        {
            xPos = x * (CD_CASE_SIZE[0] + spacing) - spacing / 2;
            yPos = y * (CD_CASE_SIZE[1] + spacing) - spacing / 2;
            translate([xPos, yPos, 0])
            Holder(backingThickness);
        }
    }
}

module BackingBoard(numCDX, numCDY, spacing, border, backingThickness, holeDepth)
{
    xSize = border * 2 + numCDX * CD_CASE_SIZE[0] + spacing * (numCDX - 1);
    ySize = border * 2 + numCDY * CD_CASE_SIZE[1] + spacing * (numCDY - 1);

    echo("Backing board is ", xSize, " mm by r=", ySize, " mm");

    // Backing board with holes for holders
    difference()
    {
        color("Sienna")
        cube([xSize, ySize, backingThickness]);

         // TODO: Make this a holder hole, not a holder as they will probably be different sizes (hole a little smaller)
        translate([border, border, backingThickness - holeDepth])
        ArrayOfHolders(numCDX, numCDY, spacing, backingThickness);
    }
}

module CDwall(numCDX, numCDY, spacing, border, backingThickness)
{
    holeDepth = backingThickness; // Cut all the way through, TODO: Should I do this?

    // Backing board
    BackingBoard(numCDX, numCDY, spacing, border, backingThickness, holeDepth)

    // ?????? !!!!!!!!!!!!!!!!!!!!!!
    translate([border, border, backingThickness - holeDepth])
    ArrayOfHolders(numCDX, numCDY, spacing, backingThickness);

    // Holders
    translate([border, border, backingThickness - holeDepth])
    ArrayOfHolders(numCDX, numCDY, spacing, backingThickness);

    // Jewel cases
    translate([border, border, backingThickness])
    ArrayOfJewelCases(numCDX, numCDY, spacing);
}

module HolderArrayForPrinting(numCDX, numCDY, spacing, backingThickness)
{
    spacing = hypotenuse(COVER_SIZE, COVER_SIZE);

    rotate([180, 0, 0])
    intersection()
    {
        translate([-HOLDER_RADIUS, -HOLDER_RADIUS, -25])
        cube([numCDX * spacing + 2 * HOLDER_RADIUS,
              numCDY * spacing + 2 * HOLDER_RADIUS,
              75]);

        for (x = [0 : 1 : numCDX])
        {
            for (y = [0 : 1 : numCDY])
            {
                translate([x * spacing, y * spacing, 0])
                Holder(backingThickness);
            }
        }
    }
}

backingThickness = 10;

//CDwall(8, 3, HOLDER_RADIUS + 2, 50, backingThickness);

//HolderArrayForPrinting(4, 3, backingThickness);

Holder(backingThickness);
